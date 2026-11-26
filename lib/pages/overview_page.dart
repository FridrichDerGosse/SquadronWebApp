import 'package:material_ui/material_ui.dart';


class OverviewPage extends StatelessWidget
{
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        const Text('Main landing frame and project summary.'),
      ],
    );
  }
}