import 'package:material_ui/material_ui.dart';
import 'package:squadron_web_app/http_helper.dart';
import 'package:squadron_web_app/misc/constants.dart';


class ServerStatusPage extends StatefulWidget
{
  const ServerStatusPage({super.key});

  @override
  State<ServerStatusPage> createState() => _ServerStatusPage();
}

class _ServerStatusPage extends State<ServerStatusPage>
{
  late final Future _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = fetchStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _statusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Failed to load: ${snapshot.error}');
        }

        final data = snapshot.data!;
        final stateText = data['status'] as int? ?? 6;
        final baseStyle = Theme.of(context).textTheme.headlineMedium ?? const TextStyle();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: baseStyle.copyWith(fontSize: 64),
                children: [
                  const TextSpan(text: 'Server Status:'),
                  TextSpan(
                    text: ' $stateText - ${statusLabel(stateText)}',
                    style: TextStyle(
                      color: statusColors(stateText),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}