import 'package:material_ui/material_ui.dart';
import 'package:squadron_web_app/http_helper.dart';
import 'package:squadron_web_app/pages/status_widget.dart';
import 'package:flutter/foundation.dart';


class AppPage extends StatefulWidget
{
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage>
{
  late final Future _statusList;

  @override
  void initState() {
    super.initState();
    _statusList = getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _statusList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Failed to load: ${snapshot.error}');
        }

        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        // debugPrint("lengh: ${items.length}: $items");

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return StatusWidget(
              username: "1", //item["username"],
              status: item["status"],
              info: item["info"]
            );
          },
        );
      },
    );
  }
}