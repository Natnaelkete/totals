import 'package:flutter/material.dart';
import 'package:totals/services/budget_service.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetStatus status;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.status,
    this.height = 10.0,
  });

  Color _getProgressColor() {
    if (status.isExceeded) {
      return const Color(0xFFFF5252);
    } else if (status.isApproachingLimit) {
      return const Color(0xFFFFB300);
    } else if (status.percentageUsed < 70) {
      return const Color(0xFF00C853);
    } else {
      return const Color(0xFF2979FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = status.percentageUsed.clamp(0.0, 100.0);
    final color = _getProgressColor();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
