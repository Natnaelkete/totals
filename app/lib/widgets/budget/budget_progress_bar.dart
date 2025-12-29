import 'package:flutter/material.dart';
import 'package:totals/services/budget_service.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetStatus status;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.status,
    this.height = 8.0,
  });

  Color _getProgressColor() {
    if (status.isExceeded) {
      return Colors.red;
    } else if (status.isApproachingLimit) {
      return Colors.orange;
    } else if (status.percentageUsed < 70) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = status.percentageUsed.clamp(0.0, 100.0);
    final color = _getProgressColor();

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: height,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
