import 'package:flutter/material.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:provider/provider.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _PlacesScreenState createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  get itemBuilder => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.title} ใกล้คุณ"),
        ),
        body: Consumer<ApplicationBloc>(
          builder: (context, provider, Widget? child) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: provider.placeResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PlaceListTile(
                      name: provider.placeResults[index].name,
                    );
                  }),
            );
          },
        ));
  }
}

class PlaceListTile extends StatelessWidget {
  const PlaceListTile({@required this.name});
  final String? name;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                name!,
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
