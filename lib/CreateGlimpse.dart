import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/database/glimpse_db.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import './config.dart' as config;
import 'database/glimpse.dart';

const Map<String, int> glimpseTypes = {
  'vertical_img_with_text_on_the_right': 0,
  'horizontal_img_with_text_below': 1,
  'horizontal_imgs': 2,
};

class CreateGlimpse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateGlimpseState();
  }
}

class _CreateGlimpseState extends State<CreateGlimpse> {
  List<Glimpse> glimpses = [];

  final GlimpseDatabaseHelper glimpseDataBaseHelper = GlimpseDatabaseHelper();

  @override
  void initState() {
    super.initState();
    print('====== CreateGlimpse init');
    fetchGlimpses();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Glimpse', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GlimpsesView(glimpses: glimpses),
              GlimpseCreator(insertGlimpse: insertGlimpse)
            ],
          ),
        ),
      ),
    );
  }

  void insertGlimpse(Glimpse glimpse) {
    setState(() {
      glimpseDataBaseHelper.insertGlimpse(glimpse);
    });
  }

  Future<void> fetchGlimpses() async {
    print('====== fetching glimpses');

    List<Glimpse> fetchedGlimpses =
        glimpses = await glimpseDataBaseHelper.getGlimpses();
    print('====== glimpses fetched');

    glimpses.forEach((element) {
      print('====== paths: ${element.imgPaths}');
    });
    setState(() {
      glimpses = fetchedGlimpses;
    });
  }
}

class GlimpsesView extends StatefulWidget {
  final List<Glimpse> glimpses;

  const GlimpsesView({Key? key, required this.glimpses}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GlimpsesViewState();
  }
}

class _GlimpsesViewState extends State<GlimpsesView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // throw UnimplementedError();

    return Container(
      height:60,
        child: ListView.builder(itemBuilder: (BuildContext context, int index) {
      return Container(
        // color: Colors.red,
        // height: 10,
        // width: 10,
        child: Text(widget.glimpses[index].imgPaths.toString()),
      );
    }));
  }
}

class GlimpseCreator extends StatefulWidget {
  final Function(Glimpse) insertGlimpse;

  const GlimpseCreator({super.key, required this.insertGlimpse});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GlimpseCreatorState();
  }
}

class _GlimpseCreatorState extends State<GlimpseCreator> {
  var imgPaths = [''];
  var types = [];
  var _typeIndex = 0;
  final CREATOR_MARGIN = 10.0;
  final SPACE_FOR_OUT_OF_DOTTED = 8.0;
  late double screenWidth;
  late double screenHeight;

  void generateTypes(double screenWidth, double screenHeight) {
    types.clear();
    types.add(GlimpseType1(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      margin: CREATOR_MARGIN,
      spaceForOutOfDotted: SPACE_FOR_OUT_OF_DOTTED,
      imagePaths: imgPaths,
      onImagePathChanged: onImagePathChanged,
    ));
    types.add(GlimpseType2(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      margin: CREATOR_MARGIN,
      spaceForOutOfDotted: SPACE_FOR_OUT_OF_DOTTED,
      imagePaths: imgPaths,
      onImagePathChanged: onImagePathChanged,
    ));
    types.add(GlimpseType3(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      margin: CREATOR_MARGIN,
      spaceForOutOfDotted: SPACE_FOR_OUT_OF_DOTTED,
      imagePaths: imgPaths,
      onImagePathChanged: onImagePathChanged,
    ));
  }

  @override
  void initState() {
    super.initState();
    // delay the execution of the code depending on the InheritedWidget
    // until after initState completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;

      setState(() {
        generateTypes(screenWidth, screenHeight);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SingleChildScrollView(
          child: Expanded(
        child: Container(
          child: Column(
            children: [
              // Text(_typeIndex.toString()),
              const Text('+'),

              Container(
                padding: EdgeInsets.all(0),
                child: DottedBorder(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      print(
                          "======triggered, details.primaryDelta ${details.primaryVelocity}");
                      setState(() {
                        // _typeIndex += details.primaryDelta ?? 0;
                        if (details.primaryVelocity! < 0) {
                          _typeIndex += 1;
                          if (_typeIndex > types.length - 1) {
                            _typeIndex = types.length - 1;
                          }
                        } else if (details.primaryVelocity! > 0) {
                          _typeIndex -= 1;
                          if (_typeIndex < 0) {
                            _typeIndex = 0;
                          }
                        }
                      });
                    },
                    child: types.isNotEmpty ? types[_typeIndex] : null,
                  ),
                ),
              ),

              Center(
                child: Container(
                  height: (screenHeight) * 0.11,
                  child: NeumorphicButton(
                      style: const NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.circle(),
                          intensity: 0.8,
                          depth: 1,
                          lightSource: LightSource.topLeft,
                          color: config.backGroundWhite,
                          border: NeumorphicBorder(
                            color: config.border,
                            width: 0.3,
                          )),
                      onPressed: () {
                        var glimpse = createGlimpse(
                            DateTime.now(), imgPaths, 'content', _typeIndex);
                        widget.insertGlimpse(glimpse);
                      },
                      child: SizedBox(
                        // color: Colors.red,
                        height: (screenHeight) * 0.05,
                        width: (screenHeight) * 0.05,

                        child: Center(
                            child: SizedBox(
                                // color: Colors.red,
                                height: (screenHeight) * 0.05,
                                width: (screenHeight) * 0.05,
                                child: const Center(
                                    child: Text(
                                  'Create',
                                  style: TextStyle(fontSize: 10),
                                )))),
                      )),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Glimpse createGlimpse(date, imgPaths, content, GType) {
    return Glimpse(
        date: date, imgPaths: imgPaths, content: content, GType: GType);
  }

  void onImagePathChanged(List<String> imagePaths) {
    imgPaths = imagePaths;

    setState(() {
      // types[_typeIndex]
      generateTypes(screenWidth, screenHeight);
    });
  }
}

class GlimpseType extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final double margin;
  final double spaceForOutOfDotted;
  final List<String> imagePaths;
  final Function(List<String>) onImagePathChanged;

  const GlimpseType({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.margin,
    required this.spaceForOutOfDotted,
    required this.imagePaths,
    required this.onImagePathChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _GlimpseTypeState extends State<GlimpseType> {
  // String? imagePathLocal;
  List<String> localImagePaths = [''];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.imagePaths[0] != '') {
      setState(() {
        localImagePaths = widget.imagePaths;
      });
    }
  }
}

class GlimpseType1 extends GlimpseType {
  const GlimpseType1(
      {super.key,
      required super.screenWidth,
      required super.screenHeight,
      required super.margin,
      required super.spaceForOutOfDotted,
      required super.imagePaths,
      required super.onImagePathChanged});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GlimpseType1State();
  }
}

class _GlimpseType1State extends _GlimpseTypeState {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.margin),
      width:
          widget.screenWidth - (widget.margin + widget.spaceForOutOfDotted) * 2,

      padding: EdgeInsets.only(
          top: widget.screenHeight * 0.05, bottom: widget.screenHeight * 0.05),
      color: Colors.white,
      // height: screenHeight * 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left side pic
          GestureDetector(
            onTap: () async {
              var imagePathFromResult = await selectAndSaveImage();
              setState(() {
                localImagePaths[0] = imagePathFromResult!;
                widget.onImagePathChanged(localImagePaths);
              });
            },
            child: Container(
              width: widget.screenWidth * 0.5,
              height: (widget.screenWidth * 0.5) / 3 * 4,
              margin: EdgeInsets.only(
                  left: widget.screenWidth * 0.05,
                  right: widget.screenWidth * 0.05),
              color: localImagePaths[0] != '' ? Colors.white : Colors.grey,
              child: localImagePaths[0] != 'null'
                  ? Visibility(
                      visible:
                          true, // Set to false if you want to hide the child
                      child: Image.file(File(localImagePaths[0])),
                    )
                  : null,
            ),
          ),

          const Expanded(
            child: Text(
              '''어떤 말을 해야 할지?
어떤 표정 지어야 할지?
아무것도 생각나지를 않아
chorus
솔직하게 말해서 나
헤어질 자신이 없어
괜찮은 척 웃으며 널
보내줄 자신이 없어 오오
chorus
네가 없는 내 하루 (하루)
하루도 (하루도) 생각한 적 없는데
나보다 나를 네가 더 잘 알면서''',
              textAlign: TextAlign.left,
              // Align text to the left
              style: TextStyle(
                // Align text to the top
                height: 1.0,
                fontSize: 12.0,
                color: Colors.black,
              ),
              softWrap: true,
              // Allow text to wrap to a new line
              maxLines: null,
              // Allow unlimited number of lines
              overflow: TextOverflow.clip, // Overflow behavior
            ),
          ),
        ],
      ),
    );
  }
}

class GlimpseType2 extends GlimpseType {
  const GlimpseType2(
      {super.key,
      required super.screenWidth,
      required super.screenHeight,
      required super.margin,
      required super.spaceForOutOfDotted,
      required super.imagePaths,
      required super.onImagePathChanged});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GlimpseType2State();
  }
}

class _GlimpseType2State extends _GlimpseTypeState {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(widget.margin),
      padding: EdgeInsets.only(
          top: widget.screenHeight * 0.05, bottom: widget.screenHeight * 0.05),
      color: Colors.white,
      width:
          widget.screenWidth - (widget.margin + widget.spaceForOutOfDotted) * 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
                onTap: () async {
                  var imagePathFromResult = await selectAndSaveImage();
                  setState(() {
                    localImagePaths[0] = imagePathFromResult!;
                    widget.onImagePathChanged(localImagePaths);
                  });
                },
                child: Container(
                    width: widget.screenWidth * 0.8,
                    height: (widget.screenWidth * 0.8) / 4 * 3,
                    // margin: EdgeInsets.only(
                    //     left: screenWidth * 0.05, right: screenWidth * 0.05),
                    color:
                        localImagePaths[0] != '' ? Colors.white : Colors.grey,
                    child: localImagePaths[0] != ''
                        ? Visibility(
                            visible: true,
                            child: Image.file(File(localImagePaths[0])))
                        : null)),
          ),
          Center(
            child: Container(
              // color: Colors.red,
              padding: EdgeInsets.only(
                  top: widget.screenHeight * 0.02,
                  left: widget.screenWidth * 0.03,
                  right: widget.screenWidth * 0.03),
              width: widget.screenWidth * 0.8,
              // Set width to match the container above
              child: const Text(
                '''어떤 말을 해야 할지?
어떤 표정 지어야 할지?
아무것도 생각나지를 않아
chorus
솔직하게 말해서 나
헤어질 자신이 없어
괜찮은 척 웃으며 널
보내줄 자신이 없어 오오
chorus
네가 없는 내 하루 (하루)
하루도 (하루도) 생각한 적 없는데
나보다 나를 네가 더 잘 알면서''',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                ),
                softWrap: true,
                maxLines: null,
                // overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlimpseType3 extends GlimpseType {
  const GlimpseType3(
      {super.key,
      required super.screenWidth,
      required super.screenHeight,
      required super.margin,
      required super.spaceForOutOfDotted,
      required super.imagePaths,
      required super.onImagePathChanged});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GlimpseType3State();
  }
}

class _GlimpseType3State extends _GlimpseTypeState {
  @override
  Widget build(BuildContext context) {
    const int fakeArrayCount = 6;
    return Container(
      padding: EdgeInsets.only(
          top: widget.screenHeight * 0.1, bottom: widget.screenHeight * 0.1),
      color: Colors.white,
      width: widget.screenWidth - (widget.spaceForOutOfDotted) * 2,
      // height: screenHeight * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: generateHorizontalContainersByImagePaths(
                      localImagePaths, widget.screenWidth, setStateCallBack)
                  // generateContainers(fakeArrayCount, widget.screenWidth),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setStateCallBack(int index) async {
    var imagePathFromResult = await selectAndSaveImage();
    if (index < localImagePaths.length) {
      localImagePaths[index] = imagePathFromResult!;
    } else {
      localImagePaths.add(imagePathFromResult!);
    }
    setState(() async {
      widget.onImagePathChanged(localImagePaths);
    });
  }
}

List<GestureDetector> generateHorizontalContainersByImagePaths(
    List<String> imagePaths,
    double screenWidth,
    Future<void> Function(int) setStateCallBack) {
  List<GestureDetector> containers = [];
  // For those who is already existed
  if (imagePaths[0] != '') {
    for (var entry in imagePaths.asMap().entries) {
      var index = entry.key;
      var element = entry.value;
      containers.add(GestureDetector(
        onTap: () async {
          await setStateCallBack(index);
        },
        child: Container(
          width: screenWidth * 0.6,
          height: (screenWidth * 0.6) / 4 * 3,
          color: imagePaths[index] != '' ? Colors.white : Colors.grey,
          margin: EdgeInsets.all(screenWidth * 0.02),
          child: Image.file(File(element)),
        ),
      ));
    }
  }
  var indexForLastOne = 0;
  if (imagePaths.length == 1 && imagePaths[0] == '') {
    // set the first '' image
    indexForLastOne = 0;
  } else {
    // add new one
    indexForLastOne = imagePaths.length;
  }

// For adding new
  containers.add(GestureDetector(
    onTap: () async {
      await setStateCallBack(indexForLastOne);
    },
    child: Container(
      width: screenWidth * 0.6,
      height: (screenWidth * 0.6) / 4 * 3,
      color: Colors.grey,
      margin: EdgeInsets.all(screenWidth * 0.02),
    ),
  ));
  return containers;
}

Future<File> saveImage(File imageFile) async {
  final appDir = await getApplicationDocumentsDirectory();
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final savedImage = File('${appDir.path}/$fileName');
  await savedImage.writeAsBytes(await imageFile.readAsBytes());
  return savedImage;
}

// Function to select an image from the gallery
Future<File?> selectImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile != null ? File(pickedFile.path) : null;
}

// Remember to call setState after call this function
Future<String?> selectAndSaveImage() async {
  final pickedFile = await selectImage();
  String? imagePath;
  if (pickedFile != null) {
    final savedImage = await saveImage(pickedFile);
    imagePath = savedImage.path;
  }
  return imagePath;
}
