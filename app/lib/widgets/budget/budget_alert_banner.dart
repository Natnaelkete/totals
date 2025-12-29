import 'package:flutter/material.dart';
import 'package:totals/services/budget_service.dart';

class BudgetAlertBanner extends StatelessWidget {
  final BudgetStatus status;

  const BudgetAlertBanner({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (!status.isExceeded && !status.isApproachingLimit) {
      return const SizedBox.shrink();
    }

    final isExceeded = status.isExceeded;
    final color = isExceeded ? Colors.red : Colors.orange;
    final icon = isExceeded ? Icons.warning : Icons.info_outline;
    final message = isExceeded
        ? '${status.budget.name} budget exceeded by ${(status.spent - status.budget.amount).toStringAsFixed(2)}'
        : '${status.budget.name} budget is ${status.percentageUsed.toStringAsFixed(1)}% used';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
