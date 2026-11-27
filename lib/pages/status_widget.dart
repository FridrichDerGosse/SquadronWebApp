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

  @override
  Widget build(BuildContext context)
  {
    return LayoutBuilder(
      builder: (context, constraints) 
      {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final scaleFactor = availableWidth / 300;

        return Card(
              child: Padding(
                padding: EdgeInsets.all(12 * scaleFactor),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 48 * scaleFactor,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(
                          width: 32 * scaleFactor,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: statusColors(status).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                                border: Border.all(
                                  color: statusColors(status).withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$status',
                                style: TextStyle(
                                  fontSize: 16 * scaleFactor,
                                ),
                                textAlign: TextAlign.center
                              ),
                            )
                          )
                        )
                      ]
                    ),
                    SizedBox(height: 2 * scaleFactor), // gap
                    Text(  // status text
                      statusLabel(status),
                      style: TextStyle(
                        color: statusColors(status),
                        fontSize: 16 * scaleFactor,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
      }
    );
  }
}
