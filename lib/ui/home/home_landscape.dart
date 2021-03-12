import 'dart:async';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc.dart';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc_event.dart';
import 'package:YOURDRS_FlutterAPP/blocs/patient/patient_bloc_state.dart';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:YOURDRS_FlutterAPP/common/app_constants.dart';
import 'package:YOURDRS_FlutterAPP/common/app_pop_menu.dart';
import 'package:YOURDRS_FlutterAPP/network/models/dictation.dart';
import 'package:YOURDRS_FlutterAPP/network/models/provider.dart';
import 'package:YOURDRS_FlutterAPP/network/models/schedule.dart';
import 'package:YOURDRS_FlutterAPP/ui/home/patient_details.dart';
import 'package:YOURDRS_FlutterAPP/widget/date_range_picker.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/dictation.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/location.dart';
import 'package:YOURDRS_FlutterAPP/widget/dropdowns/provider.dart';
import 'package:YOURDRS_FlutterAPP/widget/input_fields/search_bar.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:YOURDRS_FlutterAPP/common/app_icons.dart';

class HomeLandScape extends StatefulWidget {
  // HomeLandScape({key}) : super(key: key);
  var displayName;
  var profilePic;

  HomeLandScape({Key key, this.displayName, this.profilePic}) : super(key: key);
  @override
  _HomeLandScapeState createState() => _HomeLandScapeState();
}

//debouncer related class for Patient search related
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

class _HomeLandScapeState extends State<HomeLandScape> {
  final _debouncer = Debouncer(milliseconds: 500);
  GlobalKey _key = GlobalKey();

//var for selected Provider Id ,Dictation Id,Location Id
  var _currentSelectedProviderId;
  var _currentSelectedLocationId;
  var _currentSelectedDictationId;

// list of Patients
  List<ScheduleList> patients = List();
  List<ScheduleList> filteredPatients = List();

  TextEditingController _textFieldController = TextEditingController();

  //booean property for visibility for search and clear filter
  bool visibleSearchFilter = false;
  bool visibleClearFilter = true;

  //booean property for visibility for Date Picker
  bool datePicker = true;
  bool dateRange = false;

// Declared Variables for start Date and end Date
  String startDate;
  String endDate;
  String codeDialog;
  String valueText;

  //Lazyloading related variables
  List<int> verticalData = [];
  final int increment = 10;
  bool isLoadingVertical = false;
  @override
  void initState() {
    super.initState();
    _loadMoreVertical();
    BlocProvider.of<PatientBloc>(context).add(GetSchedulePatientsList(
        keyword1: null, providerId: null, locationId: null, dictationId: null));
  }

  //poping (Destroy)of dialog box after orientation change
  NavigatorState _navigatorState;
  bool init = false;
  bool _isOpen = false;
  @override
  void didChangeDependencies() {
    if (!init) {
      final navigator = Navigator.of(context);
      setState(() {
        _navigatorState = navigator;
      });
      init = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    print("dialog" '$_isOpen');
    if (_isOpen) {
      _navigatorState.maybePop();
    }
    super.dispose();
  }

  //Method of LazyLoading of the Scheduled patient Appointment data
  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });

    // Add in an artificial delay
    await new Future.delayed(const Duration(seconds: 2));

    verticalData.addAll(
        List.generate(increment, (index) => verticalData.length + index));

    setState(() {
      isLoadingVertical = false;
    });
  }
//filter method  for selected date

//Date Picker Controller related code
  DatePickerController _controller = DatePickerController();

  DateTime _selectedValue = DateTime.now();

//Date Picker Controller related code
  @override
  Widget build(BuildContext context) {
    var providerName = widget.displayName;
    var providerProfilePic = widget.profilePic;

    return Scaffold(
      drawer: Container(),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomizedColors.primaryColor,
        title: ListTile(
          leading: CircleAvatar(
            radius: 18,
            child: ClipOval(
              child: providerProfilePic == "null"
                  ? Image.asset(
                      AppImages.defaultImg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      providerProfilePic,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          title: Row(
            children: [
              Text(
                "Welcome",
                style: TextStyle(
                  color: CustomizedColors.textColor,
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                providerName,
                style: TextStyle(
                    color: CustomizedColors.textColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          trailing: Column(
            children: [
              Offstage(
                offstage: visibleSearchFilter,
                key: _key,
                child: FlatButton(
                  minWidth: 2,
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(
                    Icons.segment,
                    color: CustomizedColors.iconColor,
                  ),
                  onPressed: () {
                    _filterDialog(context);
                    _isOpen = true;
//
                  },
                ),
              ),
              Offstage(
                offstage: visibleClearFilter,
                child: FlatButton(
                  minWidth: 2,
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(
                    Icons.clear_all,
                    color: CustomizedColors.iconColor,
                  ),
                  onPressed: () {
                    _filterDialog(context);
                    _isOpen = true;
                  },
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.10,
              color: CustomizedColors.primaryColor,
            ),
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Column(
                  children: <Widget>[
                    PatientSerach(
                      width: 250,
                      height: 57.0,
                      onChanged: (string) {
                        _debouncer.run(() {
                          BlocProvider.of<PatientBloc>(context)
                              .add(SearchPatientEvent(keyword: string));
                        });
                      },
                    ),
                    Visibility(
                      visible: datePicker,
                      child: Container(
                        color: Colors.grey[100],
                        child: DatePicker(
                          DateTime.now().subtract(Duration(days: 3)),
                          width: 90.0,
                          height: 80,
                          controller: _controller,
                          initialSelectedDate: DateTime.now(),
                          selectionColor: CustomizedColors.primaryColor,
                          selectedTextColor: CustomizedColors.textColor,
                          dayTextStyle: TextStyle(fontSize: 10.0),
                          dateTextStyle: TextStyle(fontSize: 14.0),
                          onDateChange: (date) {
                            // New date selected
                            setState(() {
                              _selectedValue = date;
                              var selectedDate = AppConstants.parseDate(
                                  -1, AppConstants.MMDDYYYY,
                                  dateTime: _selectedValue);

                              // getSelectedDateAppointments();
                              BlocProvider.of<PatientBloc>(context).add(
                                  GetSchedulePatientsList(
                                      keyword1: selectedDate,
                                      providerId: null,
                                      locationId: null,
                                      dictationId: null));
                              print(selectedDate);
                            });
                          },
                        ),
                      ),
                    ),
                    Visibility(
                        visible: dateRange,
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Text("Selected date range is",
                                  style: TextStyle(
                                      color: CustomizedColors.buttonTitleColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${AppConstants.parseDatePattern(startDate, AppConstants.MMMddyyyy)}',
                                      style: TextStyle(
                                          color:
                                              CustomizedColors.buttonTitleColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '-',
                                      style: TextStyle(
                                          color:
                                              CustomizedColors.buttonTitleColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${AppConstants.parseDatePattern(startDate, AppConstants.MMMddyyyy)}',
                                        style: TextStyle(
                                            color: CustomizedColors
                                                .buttonTitleColor,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold))
                                  ]),
                            ])))
                  ],
                ),
              ),
            ),
            Container(
              child: Stack(
                children: <Widget>[
                  SafeArea(
                    bottom: false,
                    child: Stack(
                      children: <Widget>[
                        DraggableScrollableSheet(
                          maxChildSize: .6,
                          initialChildSize: .6,
                          minChildSize: .5,
                          builder: (context, scrollController) {
                            return Container(
                              height: 100,
                              padding: EdgeInsets.only(
                                  left: 19,
                                  right: 19,
                                  top:
                                      16), //symmetric(horizontal: 19, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30)),
                                color: CustomizedColors.textColor,
                              ),
                              child: SingleChildScrollView(
                                // physics: BouncingScrollPhysics(),
                                controller: scrollController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    BlocBuilder<PatientBloc,
                                            PatientAppointmentBlocState>(
                                        builder: (context, state) {
                                      print('BlocBuilder state $state');
                                      if (state.isLoading) {
                                        return CircularProgressIndicator();
                                      }

                                      if (state.errorMsg != null &&
                                          state.errorMsg.isNotEmpty) {
                                        return Text(state.errorMsg);
                                      }

                                      if (state.patients == null ||
                                          state.patients.isEmpty) {
                                        return Text(
                                          "No patients found",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: CustomizedColors
                                                  .noAppointment),
                                        );
                                      }

                                      // if (!isSearching) {
                                      patients = state.patients;
                                      // }

                                      if (state.keyword != null &&
                                          state.keyword.isNotEmpty) {
                                        print(
                                            'patients ${patients?.length} filtered ${filteredPatients?.length}');
                                        filteredPatients = patients
                                            .where((u) => (u.patient.displayName
                                                .toLowerCase()
                                                .contains(state.keyword
                                                    .toLowerCase())))
                                            .toList();
                                      } else {
                                        filteredPatients = patients;
                                      }

                                      return filteredPatients != null &&
                                              filteredPatients.isNotEmpty
                                          ? LazyLoadScrollView(
                                              isLoading: isLoadingVertical,
                                              onEndOfPage: () =>
                                                  _loadMoreVertical(),
                                              child: Card(
                                                child: GroupedListView<dynamic,
                                                        String>(
                                                    elements: filteredPatients,
                                                    shrinkWrap: true,
                                                    groupBy: (element) {
                                                      print(
                                                          'groupBy ${element.practice}');

                                                      return element.practice;
                                                    },
                                                    groupSeparatorBuilder: (String
                                                            practice) =>
                                                        TransactionGroupSeparator(
                                                          practice: practice,
                                                        ),
                                                    order: GroupedListOrder.ASC,
                                                    itemBuilder:
                                                        (context, element) =>
                                                            Hero(
                                                              tag: element,
                                                              child: Material(
                                                                child:
                                                                    Container(
                                                                  decoration: new BoxDecoration(
                                                                      border: new Border(
                                                                          bottom:
                                                                              new BorderSide(color: CustomizedColors.homeSubtitleColor))),
                                                                  child:
                                                                      ListTile(
                                                                    tileColor:
                                                                        CustomizedColors
                                                                            .iconColor,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .all(0),
                                                                    leading:
                                                                        Icon(
                                                                      Icons
                                                                          .bookmark,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                    onTap: () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PatientDetail(),
                                                                          // Pass the arguments as part of the RouteSettings. The
                                                                          // DetailScreen reads the arguments from these settings.
                                                                          settings:
                                                                              RouteSettings(
                                                                            arguments:
                                                                                element,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    title: Text(element
                                                                        .patient
                                                                        .displayName),
                                                                    subtitle:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                "Dr." + "" + element.providerName ?? "",
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(element.scheduleName ?? "", style: TextStyle(fontSize: 12.0)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              element.appointmentStatus ?? "",
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontSize: 12.0),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    trailing: element.dictationStatus ==
                                                                            "Pending"
                                                                        ? Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: [
                                                                              RichText(
                                                                                text: TextSpan(
                                                                                  text: '• ',
                                                                                  style: TextStyle(color: CustomizedColors.dotColor, fontSize: 16),
                                                                                  children: <TextSpan>[
                                                                                    TextSpan(text: 'Dictation' + " " + element.dictationStatus ?? "", style: TextStyle(color: CustomizedColors.dictationStatusColor, fontSize: 14)),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                5,
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                            )),
                                              ),
                                            )
                                          : Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              50, 25, 50, 45)),
                                                  Text(
                                                    "No results found for related search",
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: CustomizedColors
                                                            .noAppointment),
                                                  )
                                                ],
                                              ),
                                            );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    backgroundColor: CustomizedColors.primaryColor,
                    onPressed: () {},
                    tooltip: 'Increment',
                    child: Pop(
                      initialValue: 1,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _filterDialog(BuildContext buildContext) {
    return showDialog(
      context: buildContext,
      builder: (context) => ListView(
        children: [
          AlertDialog(
            title: Text(
              "Select a filter",
              style: TextStyle(),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(25, 0, 0, 0)),
                  ProviderDropDowns(onTapOfProviders: (newValue) {
                    print('onTap newValue $newValue');
                    setState(
                      () {
                        _currentSelectedProviderId =
                            (newValue as ProviderList).providerId;
                        print(
                            'onTap _currentSelectedProviderId $_currentSelectedProviderId');
// });
                      },
                    );
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(25, 0, 0, 0)),
                  Dictation(onTapOfDictation: (newValue) {
                    setState(() {
                      _currentSelectedDictationId =
                          (newValue as DictationStatus).dictationstatusid;

                      print(_currentSelectedDictationId);
                    });
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(25, 0, 0, 0)),
                  LocationDropDown(onTapOfLocation: (newValue) {
// setState(() {

                    _currentSelectedLocationId = newValue.locationId;

                    print(_currentSelectedLocationId);

// });
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 245,
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: CustomizedColors.homeSubtitleColor)),
                    child: RaisedButton.icon(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        onPressed: () async {
                          final List<String> result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DateFilter()));

                          startDate = result.first;

                          endDate = result.last;

                          print("range1" + startDate);

                          print("range2" + endDate);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        label: Text(
                          'Date Filter',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: CustomizedColors.buttonTitleColor),
                        ),
                        icon: Icon(Icons.date_range),

                        // textColor: Colors.red,

                        splashColor: CustomizedColors.primaryColor,
                        color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 245,
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: CustomizedColors.homeSubtitleColor)),
                    child: RaisedButton.icon(
                        padding: EdgeInsets.only(left: 25),
                        onPressed: () {
                          return showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text('Search Patients'),
                                  content: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        valueText = value;

                                        print(valueText);
                                      });
                                    },
                                    controller: this._textFieldController,
                                    decoration: InputDecoration(
                                        hintText: "Search Patients"),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      color: CustomizedColors.accentColor,
                                      textColor: Colors.white,
                                      child: Text('CANCEL'),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(ctx);
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      color: CustomizedColors.accentColor,
                                      textColor: Colors.white,
                                      child: Text('OK'),
                                      onPressed: () {
                                        setState(() {
                                          codeDialog = valueText;

                                          Navigator.pop(ctx);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        label: Text(
                          "Search Patient" ??
                              "${this._textFieldController.text}",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: CustomizedColors.buttonTitleColor,
                          ),
                        ),
                        icon: Icon(Icons.search),
                        splashColor: CustomizedColors.primaryColor,
                        color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 245,
                    margin: EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                            color: CustomizedColors.homeSubtitleColor)),
                    child: RaisedButton.icon(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        onPressed: () {
                          setState(() {
                            visibleSearchFilter = false;

                            visibleClearFilter = true;
                            datePicker = true;
                            dateRange = false;
                          });

                          Navigator.pop(context);

                          BlocProvider.of<PatientBloc>(context).add(
                              GetSchedulePatientsList(
                                  keyword1: null,
                                  providerId: null,
                                  locationId: null,
                                  dictationId: null,
                                  startDate: null,
                                  endDate: null,
                                  searchString: null));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        label: Text(
                          'Clear Filter',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: CustomizedColors.buttonTitleColor),
                        ),
                        icon: Icon(Icons.filter_alt_sharp),

                        // textColor: Colors.red,

                        splashColor: CustomizedColors.primaryColor,
                        color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      setState(() {
                        visibleSearchFilter = true;

                        visibleClearFilter = false;
                        datePicker = false;
                        dateRange = true;
                      });

                      BlocProvider.of<PatientBloc>(context).add(
                          GetSchedulePatientsList(
                              keyword1: null,
                              providerId:
                                  _currentSelectedProviderId !=
                                          null
                                      ? _currentSelectedProviderId
                                      : null,
                              locationId:
                                  _currentSelectedLocationId !=
                                          null
                                      ? _currentSelectedLocationId
                                      : null,
                              dictationId: _currentSelectedDictationId != null
                                  ? int.tryParse(_currentSelectedDictationId)
                                  : null,
                              startDate: startDate != "" ? startDate : null,
                              endDate: endDate != "" ? endDate : null,
                              searchString:
                                  this._textFieldController.text != null
                                      ? this._textFieldController.text
                                      : null));
                    },
                    child: Text('Ok'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionGroupSeparator extends StatelessWidget {
  final String practice;
  TransactionGroupSeparator({this.practice});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text(
          "${this.practice}",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
