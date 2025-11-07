import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/profile.dart';
import '../../../data/services/analytics_service.dart';
import '../../../data/services/profile_service.dart';
import '../models/table_analytics.dart';
import '../widgets/table_analytics_card.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Profile? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize with active profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileService = context.read<ProfileService>();
      if (profileService.activeProfile != null) {
        // Find the profile in the profiles list by ID to ensure we use the same instance
        final activeId = profileService.activeProfile!.id;
        final profile = profileService.profiles
            .where((p) => p.id == activeId)
            .firstOrNull;
        setState(() {
          _selectedProfile = profile ?? profileService.profiles.firstOrNull;
        });
      } else if (profileService.profiles.isNotEmpty) {
        setState(() {
          _selectedProfile = profileService.profiles.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profiles = profileService.profiles;

    // Ensure selected profile is from the current profiles list
    if (_selectedProfile != null) {
      final selectedId = _selectedProfile!.id;
      final currentProfile = profiles.where((p) => p.id == selectedId).firstOrNull;
      if (currentProfile != null && currentProfile != _selectedProfile) {
        // Update to use the instance from the profiles list
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedProfile = currentProfile;
            });
          }
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.parentDashboardTitle),
        bottom: _selectedProfile != null
            ? TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                indicatorColor: Theme.of(context).colorScheme.onPrimary,
                tabs: [
                  Tab(text: context.l10n.parentDashboardMultiplication),
                  Tab(text: context.l10n.parentDashboardAddition),
                ],
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Selector
            if (profiles.length > 1)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    Text(
                      context.l10n.parentDashboardSelectProfile,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<Profile>(
                        value: _selectedProfile,
                        isExpanded: true,
                        hint: Text(context.l10n.parentDashboardNoProfile),
                        items: profiles
                            .map(
                              (profile) => DropdownMenuItem(
                                value: profile,
                                child: Text(profile.nickname),
                              ),
                            )
                            .toList(),
                        onChanged: (profile) {
                          setState(() {
                            _selectedProfile = profile;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // Content
            Expanded(
              child: _selectedProfile == null
                  ? Center(
                      child: Text(
                        context.l10n.parentDashboardNoProfile,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTableList(OperationKind.multiplication),
                        _buildTableList(OperationKind.addition),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableList(OperationKind operation) {
    if (_selectedProfile == null) {
      return const SizedBox.shrink();
    }

    final analyticsService = context.watch<AnalyticsService>();
    final allAnalytics = analyticsService.getAllTablesAnalytics(
      profileId: _selectedProfile!.id,
      operation: operation,
    );

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allAnalytics.length,
            itemBuilder: (context, index) {
              final analytics = allAnalytics[index];
              return TableAnalyticsCard(
                analytics: analytics,
                onReset: () => _showResetTableDialog(analytics),
              );
            },
          ),
        ),
        // Reset All Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showResetAllDialog(operation),
              icon: const Icon(Icons.delete_sweep),
              label: Text(context.l10n.parentDashboardResetAll),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showResetTableDialog(TableAnalytics analytics) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.l10n.parentDashboardResetTableConfirm(analytics.table),
        ),
        content: Text(context.l10n.parentDashboardResetTableMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.parentDashboardResetCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.parentDashboardResetConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _resetTableProgress(analytics);
    }
  }

  Future<void> _resetTableProgress(TableAnalytics analytics) async {
    if (_selectedProfile == null) return;

    final analyticsService = context.read<AnalyticsService>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    try {
      await analyticsService.resetTableProgress(
        profileId: _selectedProfile!.id,
        table: analytics.table,
        operation: analytics.operation,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.parentDashboardResetTableSuccess(analytics.table),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showResetAllDialog(OperationKind operation) async {
    if (_selectedProfile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.parentDashboardResetAllConfirm),
        content: Text(
          context.l10n.parentDashboardResetAllMessage(
            _selectedProfile!.nickname,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.parentDashboardResetCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.parentDashboardResetConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _resetAllProgress();
    }
  }

  Future<void> _resetAllProgress() async {
    if (_selectedProfile == null) return;

    final analyticsService = context.read<AnalyticsService>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    try {
      await analyticsService.resetAllProgress(_selectedProfile!.id);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.parentDashboardResetAllSuccess),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

