import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:provider/provider.dart';

Widget detailTab() {
  return Consumer<ApplicationBloc>(builder: (context, provider, Widget? child) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 20),
      child: ListView(
        // shrinkWrap: true,
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ที่อยู่',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              provider.placeDetail!.address != null
                  ? Flexible(
                      child: Text(
                        provider.placeDetail!.address!,
                        style:
                            TextStyle(fontSize: 20, color: Colors.green[800]),
                      ),
                    )
                  : Text('ไม่มีข้อมูล',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      )),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'เบอร์โทรศัพท์',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          SizedBox(
            height: 5,
          ),
          provider.placeDetail!.phoneNumber != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Text(provider.placeDetail!.phoneNumber!,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.green[800],
                            )),
                      ],
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        onTap: () {
                          if (provider.placeDetail!.phoneNumber != null) {
                            Clipboard.setData(ClipboardData(
                                text: provider.placeDetail!.phoneNumber));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('คัดลอกหมายเลขโทรศัพท์แล้ว',
                                  style: GoogleFonts.sarabun(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              backgroundColor: Colors.green,
                            ));
                          }
                        },
                        child: Container(
                          width: 70,
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy,
                                color: Colors.green[800],
                                size: 20,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "คัดลอก",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green[800],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Text('ไม่มีข้อมูล',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                        )),
                  ],
                ),
          SizedBox(
            height: 15,
          ),
          Text(
            'วันเวลาเปิดทำการ',
            style: TextStyle(fontSize: 17, color: Colors.black54),
          ),
          SizedBox(
            height: 5,
          ),
          provider.placeDetail!.weekdayOpen != null
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: provider.placeDetail!.weekdayOpen!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                          provider.placeDetail!.weekdayOpen![index] + ' น.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green[800],
                          )),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text('ไม่มีข้อมูล',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      )),
                ),
        ],
      ),
    );
  });
}
