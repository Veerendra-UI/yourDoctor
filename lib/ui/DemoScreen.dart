import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';
import 'package:YOURDRS_FlutterAPP/network/repo/local/preference/local_storage.dart';
import 'package:YOURDRS_FlutterAPP/ui/login/login_screen/loginscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatelessWidget {
  var displayName;
  var profilePic;

  Welcome({Key key, this.displayName, this.profilePic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //throw UnimplementedError();
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: ClipOval(
            child: profilePic == "null"
                ? Image.asset(
                    AppImages.pinImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    profilePic,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          title: displayName == null ? Text('User Name') : Text(displayName),
        ),
      ),
      //Text(displayName), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          print('Shared Preference Cleared');
          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.remove('login');
          MySharedPreferences.instance.removeValue('memberId');
          MySharedPreferences.instance.removeValue('displayName');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        },
        icon: Icon(Icons.outbond_outlined),
        label: Text("Log Out"),
      ),
      body: Center(child: Container(child: Image.network(profilePic))),
    );
  }
}
