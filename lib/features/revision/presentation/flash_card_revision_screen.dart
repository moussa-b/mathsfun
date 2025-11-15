import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_localizations.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/table_colors.dart';
import '../../../data/models/exercise_metadata.dart';
import '../../../data/models/flash_card_result.dart';
import '../../../data/services/flash_card_service.dart';
import '../../../data/services/profile_service.dart';
import '../../exercise/models/exercise_config.dart';

enum CardStatus { notAnswered, gotIt, reviewAgain }

class FlashCardRevisionScreen extends StatefulWidget {
  const FlashCardRevisionScreen({super.key, required this.config});

  final ExerciseConfig config;

  @override
  State<FlashCardRevisionScreen> createState() =>
      _FlashCardRevisionScreenState();
}

class _FlashCardRevisionScreenState extends State<FlashCardRevisionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showAnswer = false;
  int _currentIndex = 0;
  late List<CardStatus> _cardStatuses;
  late List<_CardData> _cards;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  void _initializeCards() {
    final int table = widget.config.baseNumber;
    final bool isMultiplication =
        widget.config.operation == OperationKind.multiplication;
    
    _cards = List.generate(12, (index) {
      final int multiplier = index + 1;
      final int result = isMultiplication
          ? multiplier * table
          : multiplier + table;
      final String question = isMultiplication
          ? '$multiplier × $table'
          : '$multiplier + $table';
      return _CardData(
        question: question,
        answer: result,
        multiplier: multiplier,
      );
    });
    
    _cardStatuses = List.generate(_cards.length, (_) => CardStatus.notAnswered);
  }

  void _navigateToRevisionModeSelection(BuildContext context) {
    context.go(AppRoutePath.revisionModeType, extra: widget.config);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  void _goToNext() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
      _flipController.reset();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
      _flipController.reset();
    }
  }

  void _markCard(CardStatus status) {
    setState(() {
      _cardStatuses[_currentIndex] = status;
    });
    
    // Persist the result to database
    _persistCardResult(status);
    
    // Automatically go to next card after marking
    if (_currentIndex < _cards.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), _goToNext);
    }
  }

  Future<void> _persistCardResult(CardStatus status) async {
    final flashCardService = context.read<FlashCardService>();
    final profileService = context.read<ProfileService>();
    final activeProfile = profileService.activeProfile;
    
    if (activeProfile == null) {
      return;
    }

    final card = _cards[_currentIndex];
    final flashCardStatus = status == CardStatus.gotIt
        ? FlashCardStatus.gotIt
        : FlashCardStatus.reviewAgain;

    await flashCardService.saveResult(
      profileId: activeProfile.id,
      operation: widget.config.operation,
      table: widget.config.baseNumber,
      multiplier: card.multiplier,
      status: flashCardStatus,
    );
  }

  int get _masteredCount =>
      _cardStatuses.where((s) => s == CardStatus.gotIt).length;
  int get _reviewCount =>
      _cardStatuses.where((s) => s == CardStatus.reviewAgain).length;
  int get _notAnsweredCount =>
      _cardStatuses.where((s) => s == CardStatus.notAnswered).length;

  bool get _allCardsReviewed => _notAnsweredCount == 0;

  @override
  Widget build(BuildContext context) {
    final bool isMultiplication =
        widget.config.operation == OperationKind.multiplication;

    if (_allCardsReviewed && _currentIndex == _cards.length - 1) {
      return _buildSummaryScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _navigateToRevisionModeSelection(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => _navigateToRevisionModeSelection(context),
        ),
        title: Text(
          isMultiplication
              ? context.l10n.revisionTitleMultiplication
              : context.l10n.revisionTitleAddition,
        ),
        actions: [
          if (_notAnsweredCount < _cards.length)
            IconButton(
              icon: const Icon(Icons.emoji_events),
              onPressed: () => _showSummaryDialog(),
              tooltip: 'View Progress',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              // Progress indicator
              Text(
                context.l10n.flashCardProgress(
                  _currentIndex + 1,
                  _cards.length,
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _cards.length,
                backgroundColor: Colors.grey[300],
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 32),
              // Card
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * math.pi;
                        final transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle);

                        return Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: angle < math.pi / 2
                              ? _buildCardFront()
                              : Transform(
                                  transform: Matrix4.identity()..rotateY(math.pi),
                                  alignment: Alignment.center,
                                  child: _buildCardBack(),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons (always take up space, only visible when answer is revealed)
              Visibility(
                visible: _showAnswer,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markCard(CardStatus.reviewAgain),
                        icon: const Icon(Icons.refresh),
                        label: Text(context.l10n.flashCardReviewAgain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markCard(CardStatus.gotIt),
                        icon: const Icon(Icons.check_circle),
                        label: Text(context.l10n.flashCardGotIt),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _currentIndex > 0 ? _goToPrevious : null,
                    icon: const Icon(Icons.arrow_back),
                    label: Text(context.l10n.flashCardPrevious),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        _currentIndex < _cards.length - 1 ? _goToNext : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(context.l10n.flashCardNext),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCardFront() {
    final card = _cards[_currentIndex];
    final status = _cardStatuses[_currentIndex];
    final Color baseColor = TableColors.getTableColor(widget.config.baseNumber);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                card.question,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.flashCardTapToReveal,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 8),
              const Icon(
                Icons.touch_app,
                color: Colors.black45,
                size: 32,
              ),
            ],
          ),
        ),
        if (status != CardStatus.notAnswered)
          Positioned(
            top: 16,
            right: 16,
            child: _StatusChip(status: status),
          ),
      ],
    );
  }

  Widget _buildCardBack() {
    final card = _cards[_currentIndex];
    final status = _cardStatuses[_currentIndex];
    final Color baseColor = TableColors.getTableColor(widget.config.baseNumber);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                card.question,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black45, thickness: 2, indent: 80, endIndent: 80),
              const SizedBox(height: 16),
              Text(
                '${card.answer}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 80,
                    ),
              ),
            ],
          ),
        ),
        if (status != CardStatus.notAnswered)
          Positioned(
            top: 16,
            right: 16,
            child: _StatusChip(status: status),
          ),
      ],
    );
  }

  Widget _buildSummaryScreen() {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _navigateToRevisionModeSelection(context);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => _navigateToRevisionModeSelection(context),
        ),
        title: Text(context.l10n.flashCardSummaryTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 24),
              const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.flashCardSummaryTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _SummaryCard(
                icon: Icons.check_circle,
                color: Colors.green,
                label: context.l10n.flashCardSummaryMastered,
                count: _masteredCount,
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                icon: Icons.refresh,
                color: Colors.orange,
                label: context.l10n.flashCardSummaryToReview,
                count: _reviewCount,
              ),
              const SizedBox(height: 16),
              _SummaryCard(
                icon: Icons.help_outline,
                color: Colors.grey,
                label: context.l10n.flashCardSummaryNotAnswered,
                count: _notAnsweredCount,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _showAnswer = false;
                      _cardStatuses = List.generate(
                        _cards.length,
                        (_) => CardStatus.notAnswered,
                      );
                    });
                    _flipController.reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.flashCardRestart),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (_reviewCount > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _reviewMarkedCards,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(context.l10n.flashCardReviewMarked),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToRevisionModeSelection(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.l10n.resultsBackHome),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _reviewMarkedCards() {
    // Find first card marked for review
    final firstReviewIndex = _cardStatuses.indexWhere(
      (status) => status == CardStatus.reviewAgain,
    );

    if (firstReviewIndex == -1) {
      return;
    }

    setState(() {
      _currentIndex = firstReviewIndex;
      _showAnswer = false;
      // Reset only the cards marked for review
      for (int i = 0; i < _cardStatuses.length; i++) {
        if (_cardStatuses[i] == CardStatus.reviewAgain) {
          _cardStatuses[i] = CardStatus.notAnswered;
        }
      }
    });
    _flipController.reset();
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryCard(
              icon: Icons.check_circle,
              color: Colors.green,
              label: context.l10n.flashCardSummaryMastered,
              count: _masteredCount,
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: Icons.refresh,
              color: Colors.orange,
              label: context.l10n.flashCardSummaryToReview,
              count: _reviewCount,
            ),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: Icons.help_outline,
              color: Colors.grey,
              label: context.l10n.flashCardSummaryNotAnswered,
              count: _notAnsweredCount,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _CardData {
  const _CardData({
    required this.question,
    required this.answer,
    required this.multiplier,
  });

  final String question;
  final int answer;
  final int multiplier;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CardStatus status;

  @override
  Widget build(BuildContext context) {
    final bool isGotIt = status == CardStatus.gotIt;
    final Color background = isGotIt ? Colors.green.shade600 : Colors.orange.shade600;
    final String label = isGotIt
        ? context.l10n.flashCardGotIt
        : context.l10n.flashCardReviewAgain;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGotIt ? Icons.check_circle : Icons.refresh,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

