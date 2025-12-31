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
    final color = isExceeded ? const Color(0xFFFF5252) : const Color(0xFFFFB300);
    final icon = isExceeded ? Icons.report_gmailerrorred_rounded : Icons.info_outline_rounded;
    final message = isExceeded
        ? '${status.budget.name} budget exceeded by ${(status.spent - status.budget.amount).toStringAsFixed(2)} ETB'
        : 'Warning: ${status.budget.name} is ${status.percentageUsed.toStringAsFixed(1)}% consumed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
