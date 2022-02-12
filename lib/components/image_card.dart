import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget buildImageCard(
  BuildContext context, {
  @required VoidCallback? handler,
  @required String? imageURL,
  @required String? title,
  @required String? subTitle,
}) {
  return Card(
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    child: InkWell(
      onTap: handler,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Ink.image(
                image: CachedNetworkImageProvider(imageURL!),
                // NetworkImage(
                //   'https://firebasestorage.googleapis.com/v0/b/hdse-application.appspot.com/o/cdc-UrcuFgKfSS4-unsplash.jpg?alt=media&token=c106982f-fc65-47c3-b5cf-6d1746f6a413',
                // ),
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.srcOver),
                height: 150,
                fit: BoxFit.cover,
              ),
              Text(
                title!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.yellow[100]!, Colors.green[100]!])),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    subTitle!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
