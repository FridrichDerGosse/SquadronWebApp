import 'package:material_ui/material_ui.dart';
import 'package:squadron_web_app/http_helper.dart';
import 'package:squadron_web_app/pages/status_widget.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';


typedef JsonMap = Map<String, dynamic>;


class AppPage extends StatefulWidget
{
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage>
{
  late Future<List<JsonMap>> _itemsFuture;
  List<JsonMap> _items = [];
  bool _isSeeded = false;

  StreamSubscription? _eventStream;
  String? _streamError;
  String? _latestEventType;
  dynamic _latestEventData;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadInitialItems();
    _startEventStream();
  }

  Future<List<JsonMap>> _loadInitialItems() async {
    final loaded = await getStatus();
    final typedList = (loaded as List)
        .whereType()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    if (!_isSeeded && mounted) {
      _items = typedList;
      _isSeeded = true;
    }
    return typedList;
  }

  void _startEventStream()
  {
    _eventStream = getEventStream().listen(
      _handleEvent,
      onError: (Object error)
      {
        if (!mounted) return;
        setState(() {_streamError = '$error';});
      },
      onDone: () {debugPrint("SSE stream closed");},
      cancelOnError: false
    );
  }

  void _handleEvent(Map<String, dynamic> event)
  {
    final eventType = event['event'] as String? ?? 'message';
    final payload = event['data'];

    if (!mounted) return;
    setState(() {
      _latestEventType = eventType;
      _latestEventData = payload;
    });

    switch (eventType)
    {
    case 'user_update':
      debugPrint("User update");
      if (payload is Map) {
        _applyItemUpdate(Map<String, dynamic>.from(payload));
      }
      break;

      case 'alert':
        break;

      default:
        debugPrint('Unhandled SSE event "$eventType": $payload');
    }
  }

  void _applyItemUpdate(Map<String, dynamic> updatedItem)
  {
    final id = updatedItem['username'];
    if (id == null || !mounted) return;

    setState(() {
      final index = _items.indexWhere((item) => item['username'] == id);
      if (index != -1) {
        _items[index] = {
          ..._items[index],
          ...updatedItem,
        };
      } else {
        _items.add(updatedItem);
      }
    });
  }

  @override
  void dispose() {
    _eventStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _itemsFuture,
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

        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final availableWidth = constraints.maxWidth;

            final crossAxisCount = _items.length <= 1
                ? 1
                : (availableWidth / 340).floor().clamp(1, _items.length);

            // final tileWidth =
            //     (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
            // const tileHeight = 110.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 6 / 3,
              ),
              itemBuilder: (context, index) {
                final item = _items[index];
                return StatusWidget(
                  username: item["username"],
                  status: item["status"],
                  info: item["info"]
                );
              },
            );
          }
        );
      },
    );
  }
}