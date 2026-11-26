import 'package:material_ui/material_ui.dart';
import 'package:squadron_web_app/misc/constants.dart';


class StatusWidget extends StatelessWidget
{
  final String username;
  final int status;
  final String info;

  const StatusWidget({
    super.key,
    required this.username,
    required this.status,
    required this.info
  });

  // @override
  // State<StatusWidget> createState() => _StatusWidget();

  @override
  Widget build(BuildContext context)
  {
    return Card(
      child: ListTile(
        title: Text(username),
        subtitle: Text(
          '$status - ${statusLabel(status)}',
          style: TextStyle(
            color: statusColors(status)
          ),
        )
      )
    );
  }
}


// class _StatusWidget extends State<StatusWidget>
// {
//   @override
//   Widget build(BuildContext context)
//   {
//     return Card(
//       child: ListTile(
//         title: Text('$username')
//       )
//     );
//   }
// }
