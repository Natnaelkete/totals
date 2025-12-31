import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totals/providers/budget_provider.dart';
import 'package:totals/providers/transaction_provider.dart';
import 'package:totals/widgets/budget/budget_card.dart';
import 'package:totals/models/budget.dart';

class CategoryBudgetList extends StatelessWidget {
  final Function(Budget)? onBudgetTap;
  
  const CategoryBudgetList({super.key, this.onBudgetTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        if (budgetProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return FutureBuilder(
          future: budgetProvider.getCategoryBudgets(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final categoryBudgets = snapshot.data!;

            if (categoryBudgets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Category Budgets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Set targets for specific types of spending to gain better control.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categoryBudgets.length,
              itemBuilder: (context, index) {
                final status = categoryBudgets[index];
                return BudgetCard(
                  status: status,
                  onTap: () {
                    if (onBudgetTap != null) {
                      onBudgetTap!(status.budget);
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
