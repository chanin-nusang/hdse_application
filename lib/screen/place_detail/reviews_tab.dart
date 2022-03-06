import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hdse_application/blocs/application_bloc.dart';
import 'package:hdse_application/models/review.dart';
import 'package:hdse_application/screen/signin/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReviewsTab extends StatefulWidget {
  const ReviewsTab({Key? key, this.isSaved, this.placeID}) : super(key: key);
  final bool? isSaved;
  final String? placeID;
  @override
  _ReviewsTabState createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final _commentController = TextEditingController();
  TapGestureRecognizer? _reviewRecognizer;
  String? firstHalf;
  String? secondHalf;
  String? photoURL;
  bool flag = true;
  String? comment = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _currentSliderRatingValue = 3;
  var applicationBloc;
  @override
  void initState() {
    applicationBloc = Provider.of<ApplicationBloc>(context, listen: false);
    _reviewRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      };
    super.initState();
  }

  Widget reviewTile(Review review) {
    if (review.text!.length > 200) {
      firstHalf = review.text!.substring(0, 200);
      secondHalf = review.text!.substring(200, review.text!.length);
    } else {
      firstHalf = review.text!;
      secondHalf = "";
    }
    var reviewDate = review.time == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(review.time! * 1000, isUtc: true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Colors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Row(
                children: [
                  SizedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: review.profilePhotoURL == null
                          ? Image.asset(
                              'assets/images/avatar.png',
                              height: 40.0,
                              width: 40.0,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              width: 40.0,
                              height: 40.0,
                              imageUrl: review.profilePhotoURL!,
                              placeholder: (context, url) => Image.asset(
                                  'assets/images/avatar.png',
                                  height: 40.0,
                                  width: 40.0,
                                  fit: BoxFit.cover),
                              errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/avatar.png',
                                  height: 40.0,
                                  width: 40.0,
                                  fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.authorName ?? "ไม่มีชื่อ",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        Text(
                          reviewDate == null
                              ? "ไม่ระบุวันที่"
                              : "${reviewDate.day}/${reviewDate.month}/${reviewDate.year + 543}",
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Flexible(flex: 1, child: SizedBox()),
            Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "คะแนน",
                      style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                    ),
                    Text(
                      review.rating == null ? "-" : review.rating.toString(),
                      style: TextStyle(fontSize: 20, color: Colors.grey[800]),
                    ),
                  ],
                ))
          ],
        ),
        SizedBox(
          height: 10,
        ),
        (review.text != null && review.text != '')
            ? Container(
                padding:
                    new EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: secondHalf == ""
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          new Text(firstHalf!,
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey[800]))
                        ],
                      )
                    : new Column(
                        children: <Widget>[
                          Text(
                            flag
                                ? (firstHalf! + "...")
                                : (firstHalf! + secondHalf!),
                            style: TextStyle(
                                fontSize: 17, color: Colors.grey[800]),
                          ),
                          new InkWell(
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  flag ? "ดูเพิ่มเติม" : "ดูน้อยลง",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.green),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                          ),
                        ],
                      ),
              )
            : Container(),
        (_auth.currentUser != null && widget.isSaved == false)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _auth.currentUser!.uid == review.userID
                      ? IconButton(
                          onPressed: () {
                            _showDeleteReviewDialog(context, review);
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.grey,
                        )
                      : Container()
                ],
              )
            : Container()
      ],
    );
  }

  _showDeleteReviewDialog(BuildContext context, Review review) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
            scrollable: true,
            content: Column(
              children: [
                Icon(
                  Icons.delete_forever_outlined,
                  size: 40,
                  color: Colors.green[200],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ยืนยันที่จะลบคำวิจารณ์ออกจากสถานที่นี้',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Text(
                          "ยกเลิก",
                          style: TextStyle(fontSize: 17, color: Colors.green),
                        )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection("reviews")
                                .doc(widget.placeID)
                                .update({
                              'reviews': FieldValue.arrayRemove([
                                {
                                  'author_name': review.authorName,
                                  'author_url': review.userID,
                                  'profile_photo_url': review.profilePhotoURL,
                                  'rating': review.rating,
                                  'text': review.text,
                                  'time': review.time
                                }
                              ])
                            });

                            Navigator.of(context, rootNavigator: true).pop();
                            setState(() {
                              applicationBloc
                                  .deleteReviewInPlaceDetail(review.time);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("ลบคำวิจารณ์เรียบร้อยแล้ว",
                                  style: GoogleFonts.sarabun(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              backgroundColor: Colors.green,
                            ));
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "ไม่สามารถลบคำวิจารณ์นี้ได้ โปรดลองอีกครั้ง",
                                  style: GoogleFonts.sarabun(
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 18))),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                        child: Text(
                          "ลบ",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget bottomSheet(BuildContext context) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 20,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: _auth.currentUser?.photoURL == null
                    ? Image.asset('assets/images/avatar.png').image
                    : CachedNetworkImageProvider(_auth.currentUser!.photoURL!),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 200,
                      child: TextField(
                        autofocus: true,
                        controller: _commentController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'เพิ่มคำวิจารณ์...',
                          // suffixIcon: Icon(Icons.reviews),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => comment = value,
                        onTap: () {},
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 30,
                      child: ElevatedButton(
                          onPressed: () {
                            saveReviewToFirestore(context,
                                _currentSliderRatingValue.toInt(), comment!);
                          },
                          child: Text(
                            "ส่ง",
                            style: TextStyle(fontSize: 17),
                          )),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 190,
                      child: SliderTheme(
                          data: SliderThemeData(
                              thumbColor: Colors.green[200],
                              activeTrackColor: Colors.green[200],
                              inactiveTrackColor: Colors.green[50],
                              valueIndicatorColor: Colors.green[200]),
                          child: Slider(
                            value: _currentSliderRatingValue,
                            max: 5,
                            divisions: 5,
                            label: _currentSliderRatingValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderRatingValue = value;
                              });
                            },
                          )),
                    ),
                    Text(
                      _currentSliderRatingValue.toInt().toString() + " คะแนน",
                      style: TextStyle(fontSize: 17, color: Colors.green),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  saveReviewToFirestore(BuildContext context, int rating, String text) async {
    try {
      DocumentSnapshot snapShot = await FirebaseFirestore.instance
          .collection("reviews")
          .doc(widget.placeID)
          .get();
      print('existssssssssss : ' + snapShot.exists.toString());
      if (snapShot.exists) {
        print(snapShot.exists);
        await FirebaseFirestore.instance
            .collection("reviews")
            .doc(widget.placeID)
            .update({
          'reviews': FieldValue.arrayUnion([
            {
              'author_url': _auth.currentUser!.uid,
              'author_name': _auth.currentUser!.displayName,
              'profile_photo_url': _auth.currentUser!.photoURL,
              'rating': rating,
              'text': text,
              'time': DateTime.now().millisecondsSinceEpoch ~/
                  Duration.millisecondsPerSecond
            }
          ])
        });
      } else {
        print(snapShot.exists);
        await FirebaseFirestore.instance
            .collection("reviews")
            .doc(widget.placeID)
            .set({
          'reviews': FieldValue.arrayUnion([
            {
              'author_url': _auth.currentUser!.uid,
              'author_name': _auth.currentUser!.displayName,
              'profile_photo_url': _auth.currentUser!.photoURL,
              'rating': rating,
              'text': text,
              'time': DateTime.now().millisecondsSinceEpoch ~/
                  Duration.millisecondsPerSecond
            }
          ])
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ส่งคำวิจารณ์สำเร็จ",
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(color: Colors.white, fontSize: 18))),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
      applicationBloc.addReview(Review(
          authorName: _auth.currentUser!.displayName,
          profilePhotoURL: _auth.currentUser!.photoURL,
          userID: _auth.currentUser!.uid,
          rating: rating,
          text: text,
          time: DateTime.now().millisecondsSinceEpoch ~/
              Duration.millisecondsPerSecond));
      comment = '';
      _commentController.clear();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ไม่สามารถส่งคำวิจารณ์ได้ โปรดลองอีกครั้ง",
            style: GoogleFonts.sarabun(
                textStyle: TextStyle(color: Colors.white, fontSize: 18))),
        backgroundColor: Colors.red,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationBloc>(
        builder: (context, provider, Widget? child) {
      var detail =
          widget.isSaved! ? provider.archivedPlaceDetail : provider.placeDetail;
      if (detail!.reviews == null)
        return Center(
            child: Text(
          'ไม่มีการรีวิวในสถานที่นี้',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
        ));
      else
        return ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 10, top: 10),
              child: Column(
                children: [
                  _auth.currentUser != null
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => showModalBottomSheet(
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.0))),
                                context: context,
                                builder: (ctx) => bottomSheet(ctx)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        _auth.currentUser?.photoURL == null
                                            ? Image.asset(
                                                    'assets/images/avatar.png')
                                                .image
                                            : CachedNetworkImageProvider(
                                                _auth.currentUser!.photoURL!),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'เพิ่มคำวิจารณ์...',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: RichText(
                                      text: TextSpan(
                                          text: "กรุณา",
                                          style: GoogleFonts.sarabun(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16 *
                                                      MediaQuery.of(context)
                                                          .textScaleFactor)),
                                          children: <TextSpan>[
                                        TextSpan(
                                            recognizer: _reviewRecognizer,
                                            text: 'เข้าสู่ระบบ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green)),
                                        TextSpan(
                                            text: "เพื่อเพิ่มคำวิจารณ์ของท่าน",
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ])))
                            ],
                          ),
                        ),
                  ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: detail.reviews!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return reviewTile(detail.reviews![index]);
                      }),
                ],
              ),
            ),
          ],
        );
    });
  }
}
