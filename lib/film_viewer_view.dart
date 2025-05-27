import 'dart:math';

import 'package:exif/exif.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/common/utils/image_utils.dart';
import 'package:glimpse/rotatable_Glimpse_card_view.dart';
import 'package:photo_manager/photo_manager.dart';
import './config.dart' as config;
import 'light_box_view.dart';

class FilmViewerView extends StatefulWidget {
  final Size viewSize;
  final List<AssetEntity> images;

  const FilmViewerView(
      {super.key, required this.viewSize, required this.images});

  @override
  State<StatefulWidget> createState() {
    return _FilmViewerViewState();
  }
}

class _FilmViewerViewState extends State<FilmViewerView> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }

  Color backLight = config.backLightW;

  // Widget lightBox() {
  //   Size viewSize = widget.viewSize;
  //   return SizedBox(
  //     width: viewSize.width,
  //     height: viewSize.height,
  //     child: Stack(
  //       children: [
  //         Center(
  //           child: SizedBox(
  //             width: viewSize.width,
  //             height: viewSize.height,
  //             child: images.isEmpty
  //                 ? const Center(child: Text("No images found for this date"))
  //                 : Padding(
  //                     padding: const EdgeInsets.all(0.0),
  //                     child: Container(
  //                       color: backLight,
  //                       width: viewSize.width,
  //                       height: viewSize.height,
  //                       child: ListView.builder(
  //                         // crossAxisCount: 1,
  //                         itemCount: images.length,
  //                         itemBuilder: (context, index) {
  //                           final image = images[index];
  //                           final thumbnail = _thumbnailCache[image.id];
  //                           final isFirst = index == 0;
  //                           final isLast = index == images.length - 1;
  //
  //                           return GestureDetector(
  //                             child: Container(
  //                               child: isFirst
  //                                   ? Row(
  //                                       children: [
  //                                         const Spacer(),
  //                                         Container(
  //                                           color: const Color(0xFF8B4513)
  //                                               .withOpacity(0.65),
  //                                           child: FilmHead(
  //                                             screenWidth: viewSize.width,
  //                                             frameHeight: viewSize.height,
  //                                             backLight: backLight,
  //                                           ),
  //                                         ),
  //                                         const Spacer()
  //                                       ],
  //                                     )
  //                                   : isLast
  //                                       ? Row(
  //                                           children: [
  //                                             const Spacer(),
  //                                             Container(
  //                                               color: const Color(0xFF8B4513)
  //                                                   .withOpacity(0.65),
  //                                               child: Transform.rotate(
  //                                                 angle: pi,
  //                                                 child: FilmHead(
  //                                                   screenWidth: viewSize.width,
  //                                                   frameHeight:
  //                                                       viewSize.height,
  //                                                   backLight: backLight,
  //                                                 ),
  //                                               ),
  //                                             ),
  //                                             const Spacer(),
  //                                           ],
  //                                         )
  //                                       : Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.center,
  //                                           children: [
  //                                             const Spacer(),
  //                                             Container(
  //                                               color: const Color(0xFF8B4513)
  //                                                   .withOpacity(0.65),
  //                                               child: Stack(
  //                                                 children: [
  //                                                   Row(
  //                                                     children: [
  //                                                       const SizedBox(
  //                                                           width: 10),
  //                                                       Rectangles(
  //                                                         totalHeight:
  //                                                             frameHeight,
  //                                                         backLight: backLight,
  //                                                       ),
  //                                                       const SizedBox(
  //                                                           width: 10),
  //                                                       Container(
  //                                                         width: screenWidth *
  //                                                             filmWidthRatio,
  //                                                         decoration:
  //                                                             const BoxDecoration(
  //                                                           color: Colors.black,
  //                                                         ),
  //                                                         child: (thumbnail !=
  //                                                                 null)
  //                                                             ? GestureDetector(
  //                                                                 onTap:
  //                                                                     () async {
  //                                                                   final isNeg =
  //                                                                       backLight !=
  //                                                                           backLight;
  //
  //                                                                   // 取得圖片 bytes
  //                                                                   final imageBytes =
  //                                                                       await ImageUtils.getImageBytes(
  //                                                                           image);
  //
  //                                                                   // Get EXIF here. The exif will disappear after applying the neg. effect
  //                                                                   final exifData =
  //                                                                       await readExifFromBytes(
  //                                                                           imageBytes!);
  //
  //                                                                   // Get the path of the image
  //                                                                   final file =
  //                                                                       await image
  //                                                                           .file;
  //                                                                   final imgPath =
  //                                                                       file?.path;
  //
  //                                                                   final processedImage = isNeg
  //                                                                       ? ImageUtils.applyNegativeEffect(
  //                                                                           imageBytes)
  //                                                                       : imageBytes;
  //
  //                                                                   Navigator
  //                                                                       .push(
  //                                                                     context,
  //                                                                     MaterialPageRoute(
  //                                                                       builder:
  //                                                                           (context) =>
  //                                                                               RotatableGlimpseCardView(
  //                                                                         image:
  //                                                                             processedImage!,
  //                                                                         exifData:
  //                                                                             exifData!,
  //                                                                         imgPath:
  //                                                                             imgPath!,
  //                                                                       ),
  //                                                                     ),
  //                                                                   );
  //                                                                 },
  //                                                                 child:
  //                                                                     RawImage(
  //                                                                   image: _thumbnailCache[
  //                                                                       image
  //                                                                           .id],
  //                                                                   fit: BoxFit
  //                                                                       .cover,
  //                                                                 ),
  //                                                               )
  //                                                             : Container(
  //                                                                 color: Colors
  //                                                                         .grey[
  //                                                                     200],
  //                                                                 height: 100,
  //                                                               ),
  //                                                       ),
  //                                                       const SizedBox(
  //                                                           width: 10),
  //                                                       Rectangles(
  //                                                         totalHeight:
  //                                                             frameHeight,
  //                                                         backLight: backLight,
  //                                                       ),
  //                                                       const SizedBox(
  //                                                           width: 10),
  //                                                     ],
  //                                                   ),
  //                                                   Positioned.fill(
  //                                                       child: IgnorePointer(
  //                                                     child: Opacity(
  //                                                       opacity: 0.1,
  //                                                       child: Image.asset(
  //                                                         'assets/images/noise.png',
  //                                                         fit: BoxFit.cover,
  //                                                         color: Colors.brown
  //                                                             .withOpacity(0.2),
  //                                                         colorBlendMode:
  //                                                             BlendMode
  //                                                                 .multiply,
  //                                                       ),
  //                                                     ),
  //                                                   )),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                             const Spacer()
  //                                           ],
  //                                         ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
