import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:glimpse/widgets/rotatable_card/receipt.dart';

import '../../models/glimpse.dart';
import '../../models/receipt.dart';
import '../../services/database_service.dart';
import '../../services/glimpse_service.dart';

class FloatCardsForPackageViewMode extends StatefulWidget {
  final Size widgetSize;
  final Function setIsPackageViewMode;
  final int glimpseId;

  const FloatCardsForPackageViewMode({
    super.key,
    required this.widgetSize,
    required this.setIsPackageViewMode,
    required this.glimpseId,
  });

  @override
  State<FloatCardsForPackageViewMode> createState() =>
      _FloatCardsForPackageViewModeState();
}

class _FloatCardsForPackageViewModeState
    extends State<FloatCardsForPackageViewMode> {
  bool _loading = true;
  Glimpse? _glimpse;
  Receipt? _receipt;
  Uint8List? _scannedImageBytes;

  late final GlimpseService _service;

  @override
  void initState() {
    super.initState();
    _service = GlimpseService(DatabaseService.isar);
    _load();
  }

  Future<void> _load() async {
    final g = await _service.getGlimpseWithLinks(widget.glimpseId);

    Uint8List? scannedBytes;
    try {
      final path = g?.scannedImagePath;
      if (path != null && path.isNotEmpty) {
        final f = File(path);
        if (await f.exists()) {
          scannedBytes = await f.readAsBytes();
        }
      }
    } catch (_) {
      scannedBytes = null;
    }

    if (!mounted) return;
    setState(() {
      _glimpse = g;
      _receipt = g?.receipt.value;
      _scannedImageBytes = scannedBytes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.widgetSize.width;
    final h = widget.widgetSize.height;

    return ClipRect(
      child: Container(
        width: w,
        height: h,
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

            // 關閉
            Positioned(
              left: 0,
              top: 0,
              child: SizedBox(
                width: w * 0.2,
                height: h * 0.2,
                child: GestureDetector(
                  onTap: () => widget.setIsPackageViewMode(),
                  child: const Icon(Icons.close_rounded),
                ),
              ),
            ),

            // 內容
            Positioned.fill(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: EdgeInsets.fromLTRB(
                        w * 0.08,
                        h * 0.12,
                        w * 0.08,
                        h * 0.08,
                      ),
                      child: _buildList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final cardW = widget.widgetSize.width * 0.7;
    final cardH = widget.widgetSize.height;
    final gap = widget.widgetSize.height * 0.03;

    final children = <Widget>[];

    if (_glimpse != null && _receipt != null) {
      children.add(
        Center(
          child: SizedBox(
            width: cardW,
            height: cardH,
            child: LeftRotatableBackCardWidget(
              cardSize: Size(cardW * 0.9, cardH * 0.9),
              glimpse: _glimpse,
              receipt: _receipt,
              scannedImageBytes: null,
            ),
          ),
        ),
      );
      children.add(SizedBox(height: gap));
    }

    if (_scannedImageBytes != null) {
      children.add(
        Center(
          child: SizedBox(
            width: cardW,
            height: cardH,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              clipBehavior: Clip.none, // 不裁掉邊界
              child: Center(
                // 用 Center 控制圖片置中
                child: SizedBox(
                  width: cardW * 0.9,
                  height: cardH * 0.9,
                  child: Image.memory(
                    _scannedImageBytes!,
                    fit: BoxFit.contain, // 不要 cover，避免拉滿
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const Center(child: Text('沒有可顯示的收據或掃描圖片'));
    }

    return SizedBox(
      height: cardH,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(horizontal: widget.widgetSize.width * 0.08),
        children: children
            .map((w) => Center(child: w)) // 讓卡片在可視高度內置中
            .toList(),
      ),
    );
  }
}
