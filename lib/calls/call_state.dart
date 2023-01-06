import 'dart:io';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;

  CallLogEntry? _callLogEntries;

  Future<bool> requestPermission() async {
    var permission = await Permission.phone.request();

    switch (permission) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    setStream();
  }

  bool isLoading = false;

  void setStream() {
    PhoneState.phoneStateStream.listen((event) async {
      if (event != null) {
        setState(() {
          status = event;
          isLoading = true;
        });
        if (status == PhoneStateStatus.CALL_ENDED) {
          print(event.name);
          final Iterable<CallLogEntry> result = await CallLog.query();
          setState(() {
            _callLogEntries = result.elementAt(0);
          });
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle mono = TextStyle(fontFamily: 'monospace');
    //  final List<Widget> children = <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone State"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (Platform.isAndroid)
                MaterialButton(
                  onPressed: !granted
                      ? () async {
                          bool temp = await requestPermission();
                          setState(() {
                            granted = temp;
                            if (granted) {
                              setStream();
                            }
                          });
                        }
                      : null,
                  child: const Text("Request permission of Phone"),
                ),
              const Text(
                "Status of call",
                style: TextStyle(fontSize: 24),
              ),
              Icon(
                getIcons(),
                color: getColor(),
                size: 80,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Divider(),
                          Text(
                              'F. NUMBER  : ${_callLogEntries?.formattedNumber}',
                              style: mono),
                          Text(
                              'C.M. NUMBER: ${_callLogEntries?.cachedMatchedNumber}',
                              style: mono),
                          Text('NUMBER     : ${_callLogEntries?.number}',
                              style: mono),
                          Text('NAME       : ${_callLogEntries?.name}',
                              style: mono),
                          Text('TYPE       : ${_callLogEntries?.callType}',
                              style: mono),
                          Text('DURATION   : ${_callLogEntries?.duration}',
                              style: mono),
                          Text(
                              'ACCOUNT ID : ${_callLogEntries?.phoneAccountId}',
                              style: mono),
                          Text(
                              'SIM NAME   : ${_callLogEntries?.simDisplayName}',
                              style: mono),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getIcons() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return Icons.clear;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  Color getColor() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}
