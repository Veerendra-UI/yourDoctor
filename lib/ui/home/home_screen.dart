import 'dart:async';
import 'package:YOURDRS_FlutterAPP/ui/home/home_landscape.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/home_portrait..dart';
import 'package:flutter/material.dart';

class PatientAppointment extends StatefulWidget {
  var displayName;
  var profilePic;

  PatientAppointment({Key key, this.displayName, this.profilePic})
      : super(key: key);

  @override
  _PatientAppointmentState createState() => _PatientAppointmentState();
}

//Time delay related code
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _PatientAppointmentState extends State<PatientAppointment> {
  @override
  Widget build(BuildContext context) {
    var image = widget.profilePic;
    var providerName = widget.displayName;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    try {
      if (width > 600) {
        return HomeLandScape(
          displayName: providerName,
          profilePic: image,

        );

      } else {
        return HomePortrait(
          displayName: providerName,
          profilePic: image,
        );
      }
    } catch (e) {}
  }
}
