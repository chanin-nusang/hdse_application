import 'package:flutter/material.dart';

Widget aboutDialog(BuildContext context) {
  return AlertDialog(
    contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
    scrollable: true,
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hdse-logo-square.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            height: 70,
            width: 70,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(child: Text('แอปพลิเคชันบริการข้อมูลสุขภาพ')),
        Center(child: Text('สำหรับผู้สูงอายุ')),
        SizedBox(
          height: 5,
        ),
        Center(
          child: Text(
            'เวอร์ชัน 1.0.0',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ผู้พัฒนา',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 5),
              child: Text(
                'ชนินทร์ หนูแสง สาขาวิศวกรรมคอมพิวเตอร์ คณะวิศวกรรมศาสตร์ มหาวิทยาลัยสงขลานครินทร์',
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'ติดต่อ เสนอแนะ หรือแจ้งปัญหา',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 5),
              child: Text(
                'โทรศัพท์ 061-982-3990 อีเมล chanin.nusang@gmail.com',
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                "ปิด",
                style: TextStyle(fontSize: 17),
              )),
        ),
      ],
    ),
  );
}
