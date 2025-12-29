import 'package:totals/models/budget.dart';
import 'package:totals/services/budget_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BudgetAlertService {
  final BudgetService _budgetService = BudgetService();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _budgetChannelId = 'budgets';
  static const int _budgetNotificationIdBase = 10000;

  // Check budgets against current spending and generate alerts
  Future<List<BudgetAlert>> checkBudgetAlerts() async {
    final statuses = await _budgetService.getAllBudgetStatuses();
    final alerts = <BudgetAlert>[];

    for (final status in statuses) {
      if (status.isExceeded) {
        alerts.add(BudgetAlert(
          budget: status.budget,
          status: status,
          alertType: BudgetAlertType.exceeded,
          message: _getExceededMessage(status),
        ));
      } else if (status.isApproachingLimit) {
        alerts.add(BudgetAlert(
          budget: status.budget,
          status: status,
          alertType: BudgetAlertType.approaching,
          message: _getApproachingMessage(status),
        ));
      }
    }

    return alerts;
  }

  String _getExceededMessage(BudgetStatus status) {
    final overAmount = status.spent - status.budget.amount;
    return '${status.budget.name} budget exceeded by ${_formatCurrency(overAmount)}';
  }

  String _getApproachingMessage(BudgetStatus status) {
    final percentage = status.percentageUsed.toStringAsFixed(1);
    return '${status.budget.name} budget is ${percentage}% used';
  }

  String _formatCurrency(double amount) {
    return 'ETB ${amount.toStringAsFixed(2)}';
  }

  // Send notification for budget alerts
  Future<void> sendBudgetAlertNotification(BudgetAlert alert) async {
    try {
      final title = alert.alertType == BudgetAlertType.exceeded
          ? 'Budget Exceeded'
          : 'Budget Warning';

      final id = _budgetNotificationIdBase + (alert.budget.id ?? 0);

      await _plugin.show(
        id,
        title,
        alert.message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _budgetChannelId,
            'Budget Alerts',
            channelDescription: 'Notifications for budget warnings and alerts',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      // Handle notification error silently
      print('debug: Failed to show budget alert notification: $e');
    }
  }

  // Check and send notifications for all budget alerts
  Future<void> checkAndNotifyBudgetAlerts() async {
    final alerts = await checkBudgetAlerts();
    for (final alert in alerts) {
      await sendBudgetAlertNotification(alert);
    }
  }
}

class BudgetAlert {
  final Budget budget;
  final BudgetStatus status;
  final BudgetAlertType alertType;
  final String message;

  BudgetAlert({
    required this.budget,
    required this.status,
    required this.alertType,
    required this.message,
  });
}

enum BudgetAlertType {
  approaching,
  exceeded,
}
