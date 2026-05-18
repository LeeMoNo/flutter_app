import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/counter_viewmodel.dart';
import '../../utils/counter_formatter.dart';

class CounterView extends StatelessWidget {
  const CounterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CounterViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const CircularProgressIndicator();
        }
        
        return Column(
          children: [
            Text(
              CounterFormatter.formatCount(viewModel.count),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This is your ${CounterFormatter.formatAsOrdinal(viewModel.count)} click',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        );
      },
    );
  }
}
