import 'package:material_ui/material_ui.dart';


String statusLabel(int? code) {
  return switch (code) {
    1 => 'Standby',
    2 => 'Ready',
    3 => 'Coming',
    4 => 'Online',
    5 => 'Request',
    6 => 'Offline',
    7 => 'Leaving',
    8 => 'Away',
    9 => 'Pause',
    _ => 'Unknown (${code ?? 'none'})',
  };
}


Color statusColors(int? code) {
  return switch (code) {
    1 => Colors.grey,
    2 => Colors.cyan,
    3 => Colors.grey,
    4 => Colors.green,
    5 => Colors.grey,
    6 => Colors.grey,
    7 => Colors.grey,
    8 => Colors.grey,
    9 => Colors.grey,
    _ => Colors.grey,
  };
}
