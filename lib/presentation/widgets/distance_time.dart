
import 'package:flutter/material.dart';
import 'package:maps/constants/app_colors.dart';
import 'package:maps/data/models/place_directions.dart';

class DistanceTime extends StatelessWidget {
  final PlaceDirections? placeDirections;
  final bool isTimeAndDistanceVisible;
  const DistanceTime({Key? key, this.placeDirections,required this.isTimeAndDistanceVisible}) :
        super(key: key);

  Widget distanceTimeCard(IconData icon, String txt) {
    return Flexible(
        flex: 1,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          color: Colors.white,
          child: ListTile(
            dense: true,
            horizontalTitleGap: 0,
            leading: Icon(icon, color: AppColors.blue, size: 30,),
            title: Text(txt,
              style: const TextStyle(color: Colors.black,fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isTimeAndDistanceVisible,
        child: Positioned(
          top: 0,
            bottom: 570,
            left: 0,
            right: 0,
            child: Row(
              children: [
                distanceTimeCard(Icons.access_time_filled, placeDirections!.totalDuration),
                const SizedBox(width: 30,),
                distanceTimeCard(Icons.directions_car_filled, placeDirections!.totalDistance),
              ],
            ),
        ),
    );
  }
}
