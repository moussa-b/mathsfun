import 'package:flutter/material.dart';

class TableSelector extends StatelessWidget {
  const TableSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 12,
    this.label,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(label!, style: theme.textTheme.titleMedium),
          ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List<Widget>.generate(max, (int index) {
            final int currentValue = index + 1;
            final bool isSelected = currentValue == value;
            return ChoiceChip(
              label: Text(currentValue.toString()),
              selected: isSelected,
              onSelected: (_) => onChanged(currentValue),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            );
          }),
        ),
      ],
    );
  }
}
