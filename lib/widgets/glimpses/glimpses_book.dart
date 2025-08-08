import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:exif/exif.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/config.dart' as config;
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/widgets/rotatable_card/left_rotatable_Glimpse_card.dart';
import 'package:isar/isar.dart';

import '../../services/glimpse_service.dart';
import '../../views/glimpse_form_view.dart';

class GlimpseBookView extends StatefulWidget {
  final Size widgetSize;

  const GlimpseBookView({super.key, required this.widgetSize});

  @override
  State<GlimpseBookView> createState() => _GlimpseBookViewState();
}

class _GlimpseBookViewState extends State<GlimpseBookView> {
  List<Map<String?, IfdTag>?> exifList = [];
  List<Glimpse> glimpses = [];
  List<Uint8List?> imageBytes = [];
  bool loading = true;
  int currentIndex = 0;

  bool isDraggingPreviousPage = false;
  bool isAnyCardAnimating = false;
  bool isZoomMode = false;

  late GlimpseService glimpseService;

  @override
  void initState() {
    super.initState();
    glimpseService = GlimpseService(DatabaseService.isar);
    loadGlimpses();
  }

  Future<void> loadGlimpsesold() async {
    final isar = DatabaseService.isar;
    final loaded = await isar.glimpses.where().sortByCreatedAtDesc().findAll();

    final List<Uint8List?> byteList = [];
    final List<Map<String?, IfdTag>?> exifDataList = [];

    for (final g in loaded) {
      try {
        final file = File(g.photoPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          byteList.add(bytes);
          final exif = await readExifFromBytes(bytes);
          exifDataList.add(exif);
        } else {
          byteList.add(null);
          exifDataList.add(null);
        }
      } catch (_) {
        byteList.add(null);
        exifDataList.add(null);
      }
    }

    setState(() {
      glimpses = loaded;
      imageBytes = byteList;
      exifList = exifDataList;
      loading = false;
    });
  }

  Future<void> loadGlimpses() async {
    final service = GlimpseService(DatabaseService.isar);
    final latestGlimpses = await service.getAllGlimpsesWithLinks();

    final List<Map<String?, IfdTag>?> exifDataList = [];
    final List<Uint8List?> updatedImageBytes = [];

    for (final g in latestGlimpses) {
      Uint8List? bytes;
      try {
        final file = File(g.photoPath);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
          final exif = await readExifFromBytes(bytes);
          exifDataList.add(exif);
        } else {
          exifDataList.add(null);
        }
      } catch (_) {
        bytes = null;
        exifDataList.add(null);
      }
      updatedImageBytes.add(bytes);
    }

    setState(() {
      glimpses = latestGlimpses;
      imageBytes = updatedImageBytes;
      exifList = exifDataList;
      loading = false;
    });
  }

  void leaveCardMode() => Navigator.of(context).pop();

  void setCardAnimationState(bool animating) {
    setState(() {
      isAnyCardAnimating = animating;
    });
  }

  void onFlipCompleted(
      bool didFlipPage, bool isDraggingPreviousPage, int index) {
    print(
        '====== onFlipCompleted, index: ${index.toString()}, didFlipPage: ${didFlipPage ? 'true' : 'false'}, isDraggingPreviousPage ${isDraggingPreviousPage ? 'true' : 'false'}');
    setState(() {
      if (!isDraggingPreviousPage &&
          didFlipPage &&
          index == currentIndex &&
          currentIndex < glimpses.length) {
        print(
            '====== currentIndex added, currentIndex: ${currentIndex}, index: ${index}');
        currentIndex++;
      } else if (isDraggingPreviousPage &&
          didFlipPage &&
          index == currentIndex - 1 &&
          currentIndex > 0) {
        currentIndex--;
        print(
            '====== currentIndex min, currentIndex: ${currentIndex}, index: ${index}');
      }
    });
  }

  int? draggingCardIndex;
  bool draggingFromPrevious = false;

  void setDraggingContext(bool fromPrevious, int draggingIndex) {
    setState(() {
      draggingFromPrevious = fromPrevious;
      draggingCardIndex = draggingIndex;
    });
  }

  void buildCards(List<Widget> cards) {
    final cardSize =
        Size(widget.widgetSize.width * 0.5, widget.widgetSize.height * 0.55);

    for (int i = 0; i < glimpses.length; i++) {
      final img = (i >= 0 && i < imageBytes.length) ? imageBytes[i] : null;
      if (img == null) continue;

      final isSecondPrevious = (i == currentIndex - 2);
      final isNext = i == currentIndex + 1;

      if (isSecondPrevious || isNext) {
        final card = LeftRotatableGlimpseCard(
          key: ValueKey<Object>(
            Object.hash(
              glimpses[i].id,
              glimpses[i].receipt.value, // receipt reference 會改變
            ),
          ),
          isAnyCardAnimating: isAnyCardAnimating,
          setCardAnimationState: setCardAnimationState,
          index: i,
          image: img,
          exifData: exifList[i] ?? {},
          imagePath: glimpses[i].photoPath,
          backLight: config.backLightB,
          isNeg: false,
          cardSize: cardSize,
          leaveCardMode: leaveCardMode,
          rotationAlignment: Alignment.centerLeft,
          widgetSize: widget.widgetSize,
          onFlipCompleted: onFlipCompleted,
          isPrevious: false,
          isCurrent: false,
          setDraggingContext: setDraggingContext,
          isSecondPrevious: i == currentIndex - 2,
          glimpse: glimpses[i],
          receipt: glimpses[i].receipt.value,
        );

        cards.add(card);
      }
    }

    LeftRotatableGlimpseCard? currentCard;
    LeftRotatableGlimpseCard? previousCard;

    //  currentIndex
    if (currentIndex >= 0 && currentIndex < glimpses.length) {
      final img = imageBytes[currentIndex];
      if (img != null) {
        currentCard = LeftRotatableGlimpseCard(
          key: ValueKey<Object>(
            Object.hash(
              glimpses[currentIndex].id,
              glimpses[currentIndex].receipt.value, // receipt reference 會改變
            ),
          ),
          isAnyCardAnimating: isAnyCardAnimating,
          setCardAnimationState: setCardAnimationState,
          index: currentIndex,
          image: img,
          exifData: exifList[currentIndex] ?? {},
          imagePath: glimpses[currentIndex].photoPath,
          backLight: config.backLightB,
          isNeg: false,
          cardSize: cardSize,
          leaveCardMode: leaveCardMode,
          rotationAlignment: Alignment.centerLeft,
          widgetSize: widget.widgetSize,
          onFlipCompleted: onFlipCompleted,
          isPrevious: false,
          isSecondPrevious: false,
          isCurrent: true,
          setDraggingContext: setDraggingContext,
          glimpse: glimpses[currentIndex],
          receipt: glimpses[currentIndex].receipt.value,
          // setIsDraggingPreviousPage: setIsDraggingPreviousPage,
        );
      }
    }

    // previous
    if (currentIndex - 1 >= 0) {
      final img = imageBytes[currentIndex - 1];

      if (img != null) {
        previousCard = LeftRotatableGlimpseCard(
          key: ValueKey<Object>(
            Object.hash(
              glimpses[currentIndex - 1].id,
              glimpses[currentIndex - 1].receipt.value, // receipt reference 會改變
            ),
          ),
          isAnyCardAnimating: isAnyCardAnimating,
          setCardAnimationState: setCardAnimationState,
          index: currentIndex - 1,
          image: img,
          exifData: exifList[currentIndex - 1] ?? {},
          imagePath: glimpses[currentIndex - 1].photoPath,
          backLight: config.backLightB,
          isNeg: false,
          cardSize: cardSize,
          leaveCardMode: leaveCardMode,
          rotationAlignment: Alignment.centerLeft,
          widgetSize: widget.widgetSize,
          onFlipCompleted: onFlipCompleted,
          isPrevious: true,
          isSecondPrevious: false,
          isCurrent: false,
          setDraggingContext: setDraggingContext,
          glimpse: glimpses[currentIndex - 1],
          receipt: glimpses[currentIndex - 1].receipt.value,
        );
      }
    }

    if (previousCard != null && previousCard.index != draggingCardIndex) {
      cards.add(previousCard);
    }
    if (currentCard != null && currentCard.index != draggingCardIndex) {
      cards.add(currentCard);
    }

    // 把正在拖曳的那張放在最上層
    if (draggingCardIndex == previousCard?.index && previousCard != null) {
      cards.add(previousCard);
    }
    if (draggingCardIndex == currentCard?.index && currentCard != null) {
      cards.add(currentCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (glimpses.isEmpty) {
      return const Text('No glimpse');
    }

    final List<Widget> cards = [];
    buildCards(cards);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('currentIndex: $currentIndex'),
                Text('length: ${glimpses.length}'),
                Text('isAni: ${isAnyCardAnimating}'),
              ],
            ),
          ),

          // 卡片們
          ...cards,

          // delete and zoom
          if (currentIndex >= 0 && currentIndex < glimpses.length) ...[
            Positioned(
                bottom: widget.widgetSize.height * 0.05,
                right: widget.widgetSize.width * 0.05,
                child: ZoomButton(
                  widgetSize: Size(widget.widgetSize.width * 0.2,
                      widget.widgetSize.height * 0.1),
                  setIsZoomMode: setIsZoomMode,
                )),
            Positioned(
              bottom: widget.widgetSize.height * 0.05,
              right: widget.widgetSize.width * 0.25,
              child: DeleteButton(
                widgetSize: Size(widget.widgetSize.width * 0.2,
                    widget.widgetSize.height * 0.1),
                glimpse: glimpses[currentIndex],
                glimpseService: glimpseService, // ✅ 傳進去
                onDeleted: () async {
                  await loadGlimpses();
                  setState(() {
                    if (currentIndex > 0) currentIndex--;
                  });
                },
              ),
            ),
          ],

          if (currentIndex >= 1)
            Positioned(
                bottom: widget.widgetSize.height * 0.05,
                left: widget.widgetSize.width * 0.05,
                child: EditButton(
                  widgetSize: Size(widget.widgetSize.width * 0.2,
                      widget.widgetSize.height * 0.1),
                  imagePath: glimpses[currentIndex - 1].photoPath,
                  exifData: exifList[currentIndex - 1] ?? <String?, IfdTag>{},
                  glimpseId: glimpses[currentIndex - 1].id,
                  onEdited: () async {
                    await loadGlimpses();
                    setState(() {
                      // ✅ 什麼都不做，只是觸發 rebuild
                    });
                  },
                )),

          if (isZoomMode)
            Positioned(
                top: 0,
                left: 0,
                child: FloatCardForZoomMode(
                  widgetSize: widget.widgetSize,
                  imageByte: imageBytes[currentIndex],
                  setIsZoomMode: setIsZoomMode,
                ))
        ],
      ),
    );
  }

  void setIsZoomMode() {
    setState(() {
      isZoomMode = isZoomMode == true ? false : true;
    });
  }

  void debugPrintMapTable(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return;

    final keys = list.first.keys.toList();
    print(keys.join('\t'));

    for (var item in list) {
      print(keys.map((k) => item[k].toString()).join('\t'));
    }
  }
}

class ZoomButton extends StatefulWidget {
  final Size widgetSize;
  final Function setIsZoomMode;

  const ZoomButton({
    super.key,
    required this.widgetSize,
    required this.setIsZoomMode,
  });

  @override
  State<ZoomButton> createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<ZoomButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // 稍微下沉
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 彈回
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0; // 取消時恢復
    });
  }

  void _onTap() {
    // 這裡放你的 zoom in 邏輯
    widget.setIsZoomMode();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          // color: Colors.red,
          width: widget.widgetSize.width,
          height: widget.widgetSize.height,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.widgetSize.height),
            ),
            elevation: 1.5,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Icon(Icons.zoom_in),
            ),
          ),
        ),
      ),
    );
  }
}

class EditButton extends StatefulWidget {
  final Size widgetSize;
  final String imagePath;
  final int glimpseId;
  final Map<String?, IfdTag> exifData;
  final Function() onEdited;

  const EditButton({
    super.key,
    required this.widgetSize,
    required this.imagePath,
    required this.exifData,
    required this.glimpseId,
    required this.onEdited,
  });

  @override
  State<EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // 稍微下沉
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 彈回
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0; // 取消時恢復
    });
  }

  Future<void> _onTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlimpseFormView(
          photoPath: widget.imagePath,
          exifData: widget.exifData!,
          glimpseId: widget.glimpseId,
        ),
      ),
    );

    print('======(book)result: $result');

    if (result == true) {
      widget.onEdited();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          // color: Colors.red,
          width: widget.widgetSize.width,
          height: widget.widgetSize.height,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.widgetSize.height),
            ),
            elevation: 1.5,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Icon(Icons.edit_note),
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteButton extends StatefulWidget {
  final Size widgetSize;
  final Glimpse glimpse;
  final Function onDeleted;
  final GlimpseService glimpseService;

  const DeleteButton(
      {super.key,
      required this.widgetSize,
      required this.glimpse,
      required this.onDeleted,
      required this.glimpseService});

  @override
  DeleteButtonState createState() => DeleteButtonState();
}

class DeleteButtonState extends State<DeleteButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95; // 稍微下沉
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // 彈回
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  Future<void> _onTap() async {
    final isReceiptLinkedOnlyToThisGlimpse = await widget.glimpseService
        .isReceiptLinkedOnlyToThisGlimpse(widget.glimpse);

    print(
        '======on tap: isReceiptLinkedOnlyToThisGlimpse: ${isReceiptLinkedOnlyToThisGlimpse}');

    if (isReceiptLinkedOnlyToThisGlimpse) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('這張收據只連結這一張照片，是否也一併刪除收據？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('只刪照片'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('刪除照片和收據'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await widget.glimpseService.deleteGlimpseAndReceipt(widget.glimpse);
      } else {
        await widget.glimpseService.deleteGlimpse(widget.glimpse);
      }
    } else {
      await widget.glimpseService.deleteGlimpse(widget.glimpse);
    }

    widget.onDeleted(); // 通知上層重載
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: SizedBox(
          width: widget.widgetSize.width,
          height: widget.widgetSize.height,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.widgetSize.height),
            ),
            elevation: 1.5,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Icon(Icons.delete),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatCardForZoomMode extends StatefulWidget {
  final Size widgetSize;
  final Uint8List? imageByte;
  final Function setIsZoomMode;

  const FloatCardForZoomMode({
    super.key,
    required this.widgetSize,
    this.imageByte,
    required this.setIsZoomMode,
  });

  @override
  State<FloatCardForZoomMode> createState() => _FloatCardForZoomModeState();
}

class _FloatCardForZoomModeState extends State<FloatCardForZoomMode>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  double _baseScale = 1.0;

  Offset _offset = Offset.zero;
  Offset _startOffset = Offset.zero;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  bool _hasDragged = false;
  int _pointerCount = 0; // ✅ 用來追蹤目前螢幕上的手指數量

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addListener(() {
      setState(() {
        _offset = _offsetAnimation.value;
      });
    });
  }

  void _animateBackToCenter() {
    _offsetAnimation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseWidth = widget.widgetSize.width * 0.8;
    final double scaledWidth = baseWidth * _scale;

    return ClipRect(
      child: Container(
        width: widget.widgetSize.width,
        height: widget.widgetSize.height,
        color: Colors.transparent,
        child: Stack(
          children: [
            // 背景模糊
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.88),
                          Colors.white.withOpacity(0.98),
                          Colors.white.withOpacity(0.88),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (widget.imageByte != null)
              Listener(
                onPointerDown: (_) {
                  _pointerCount++;
                },
                onPointerUp: (_) {
                  _pointerCount--;
                  if (_pointerCount <= 0 && _hasDragged) {
                    _animateBackToCenter();
                    _hasDragged = false;
                  }
                },
                child: GestureDetector(
                  onScaleStart: (details) {
                    _controller.stop(); // 拖曳中斷動畫
                    _baseScale = _scale;
                    _startOffset = _offset;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _scale = (_baseScale * details.scale).clamp(0.5, 3.0);
                      if (details.pointerCount == 1) {
                        _offset += details.focalPointDelta;
                        _hasDragged = true; // ✅ 確實拖移了
                      }
                    });
                  },
                  onScaleEnd: (details) {
                    // ❌ 不再這裡觸發彈回
                  },
                  child: Center(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: Transform.translate(
                        offset: _offset,
                        child: SizedBox(
                          width: scaledWidth,
                          child: ClipRRect(
                            child: Image.memory(
                              widget.imageByte!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: widget.widgetSize.width * 0.2,
                  height: widget.widgetSize.height * 0.2,
                  child: GestureDetector(
                    onTap: () => {widget.setIsZoomMode()},
                    child: const Icon(Icons.close_rounded),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
