import 'package:flutter/material.dart';

class TableSelector extends StatelessWidget {
  const TableSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 12,
    this.label,
    this.multiSelect = false,
    this.selectedValues,
    this.onMultiChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final String? label;
  final bool multiSelect;
  final Set<int>? selectedValues;
  final ValueChanged<Set<int>>? onMultiChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Calculate columns based on max: 6 for multiplication (12), 5 for addition (10)
    final int crossAxisCount = max == 12 ? 6 : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(label!, style: theme.textTheme.titleMedium),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: max,
          itemBuilder: (BuildContext context, int index) {
            final int currentValue = index + 1;
            final bool isSelected = multiSelect 
                ? (selectedValues?.contains(currentValue) ?? false)
                : currentValue == value;
            return _NumberChip(
              number: currentValue,
              isSelected: isSelected,
              onTap: () {
                if (multiSelect && onMultiChanged != null) {
                  final Set<int> newSelection = Set<int>.from(selectedValues ?? {});
                  if (newSelection.contains(currentValue)) {
                    // Don't allow deselecting if it's the last one
                    if (newSelection.length > 1) {
                      newSelection.remove(currentValue);
                    }
                  } else {
                    newSelection.add(currentValue);
                  }
                  onMultiChanged!(newSelection);
                } else {
                  onChanged(currentValue);
                }
              },
              theme: theme,
            );
          },
        ),
      ],
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({
    required this.number,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final int number;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = theme.colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : null,
            ),
          ),
        ),
      ),
    );
  }
}
