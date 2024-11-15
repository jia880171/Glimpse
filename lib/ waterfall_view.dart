import 'dart:typed_data';
import './config.dart' as config;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WaterfallView extends StatefulWidget {
  final DateTime selectedDate;

  const WaterfallView({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _WaterfallViewState createState() => _WaterfallViewState();
}

class _WaterfallViewState extends State<WaterfallView> {
  List<AssetEntity> images = [];
  int counts = 0;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  // 定義一個縮略圖快取Map
  Map<String, Uint8List?> _thumbnailCache = {};

  Future<void> _fetchImages() async {
    print('======_fetchImages');
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();
    print('====== permission ${permission.toString()}');

    // Check if permission is authorized
    if (permission.isAuth || permission == PermissionState.limited) {
      print('====== permission is authed(or limited)');
      // Fetch albums from the device
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList();
      print('====== albums ${albums}');

      if (albums.isNotEmpty) {
        final List<AssetEntity> allImages =
            await albums[0].getAssetListPaged(page: 0, size: 100);

        // Filter images by selected date
        final selectedImages = allImages.where((image) {
          final DateTime? createDate = image.createDateTime;
          return createDate?.year == widget.selectedDate.year &&
              createDate?.month == widget.selectedDate.month &&
              createDate?.day == widget.selectedDate.day;
        }).toList();

        // 加載縮略圖並快取
        for (var image in selectedImages) {
          _thumbnailCache[image.id] = await image.thumbnailDataWithSize(
            const ThumbnailSize(300, 300),
          );
        }

        setState(() {
          print('====== count: ${counts}');
          images = selectedImages;
          counts = images.length;
        });
      } else {
        print('====== albums is empty');
      }
    } else {
      print('====== permission is not authed');
      PhotoManager.openSetting();
    }
  }

  @override
  void didUpdateWidget(WaterfallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      // Only fetch images if selectedDate has changed
      _fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('====== building');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeForText = 20;

    return Scaffold(
        backgroundColor: config.backGroundWhite,
        body: SingleChildScrollView(
          child: SizedBox(
              height: screenWidth,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Expanded(
                          child: Container(
                            width: screenWidth,
                            height: screenHeight,
                            child: images.isEmpty
                                ? const Center(
                                child: Text("No images found for this date"))
                                : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: config.backGroundWhite,
                                child: MasonryGridView.count(
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 300,
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    final image = images[index];
                                    final thumbnail =
                                    _thumbnailCache[image.id];

                                    if (thumbnail != null) {
                                      return Image.memory(
                                        thumbnail,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    // 加載過程中的占位
                                    return Container(
                                      color: Colors.grey[200],
                                      height: 100,
                                    );
                                  },
                                ),
                              ),
                            ),
                          )),

                      Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),

                              // year
                              SizedBox(
                                width: fontSizeForText * 4,
                                child: Text(
                                  widget.selectedDate.year.toString(),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSizeForText,
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                  ),
                                ),
                              ),

                              // /
                              SizedBox(
                                child: Text(
                                  '/',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSizeForText,
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                  ),
                                ),
                              ),

                              // month
                              SizedBox(
                                width: fontSizeForText * 2,
                                child: Text(
                                  widget.selectedDate.month < 10
                                      ? '0${widget.selectedDate.month}'
                                      : widget.selectedDate.month.toString(),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSizeForText,
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                  ),
                                ),
                              ),

                              // /
                              SizedBox(
                                child: Text(
                                  '/',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSizeForText,
                                    fontWeight: FontWeight.w500,
                                    fontFamily:
                                        'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                  ),
                                ),
                              ),

                              // date
                              SizedBox(
                                  width: fontSizeForText * 2,
                                  child: Text(
                                    widget.selectedDate.day < 10
                                        ? '0${widget.selectedDate.day}'
                                        : widget.selectedDate.day.toString(),
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: fontSizeForText,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'Ds-Digi', // Replace 'FirstFontFamily' with your desired font family
                                    ),
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              Text('counts: ${counts}'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )),
        ));
  }
}
