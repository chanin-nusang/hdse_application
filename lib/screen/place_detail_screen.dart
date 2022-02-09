import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/place_detail.dart';
import 'package:provider/provider.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({Key? key, this.placeID}) : super(key: key);
  final String? placeID;
  @override
  _PlaceDetailScreenState createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  PlaceDetail? placeDetail;
  var applicationBloc;
  @override
  void initState() {
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    Provider.of<ApplicationBloc>(context, listen: false)
        .getPlaceDetailToBloc(widget.placeID!);
    super.initState();
  }

  @override
  void dispose() {
    applicationBloc.clearPlaceDetail();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดสถานที่'),
      ),
      body: Consumer<ApplicationBloc>(
          builder: (context, provider, Widget? child) {
        if (provider.placeDetail == null)
          return CircularProgressIndicator();
        else
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Column(children: [Text(provider.placeDetail!.name ?? '')]),
          );
      }),
    );
  }
}
