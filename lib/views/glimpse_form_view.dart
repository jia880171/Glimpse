import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/views/Edge_detection_view.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config.dart' as config;
import '../models/friend.dart';
import '../models/journal.dart';
import '../models/receipt.dart';
import '../models/shop_type.dart';
import '../services/glimpse_service.dart';

class GlimpseFormView extends StatefulWidget {
  final String photoPath;
  final Map<String?, IfdTag> exifData;
  final int? glimpseId;

  const GlimpseFormView({
    Key? key,
    required this.photoPath,
    required this.exifData,
    this.glimpseId,
  }) : super(key: key);

  @override
  State<GlimpseFormView> createState() => _GlimpseFormViewState();
}

class _GlimpseFormViewState extends State<GlimpseFormView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _lensController;
  late TextEditingController _shutterController;
  late TextEditingController _apertureController;
  late TextEditingController _isoController;
  late TextEditingController _countryController;
  late TextEditingController _prefectureController;
  late TextEditingController _cityController;
  late TextEditingController _placeNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _totalCostController;
  late TextEditingController _journalTitleController;
  late TextEditingController _journalContentController;


  DateTime? _exifDateTime;
  String scannedImagePath = '';

  late Glimpse _glimpse;

  Receipt? _receipt;
  Journal? _journal;

  ShopType? _selectedShopType;
  List<Friend> _allFriends = [];
  List<Friend> _selectedFriends = [];
  List<ShopType> _allShopTypes = [];

  String appBarText = '';
  late double screenHeight;
  late double screenWidth;

  @override
  void initState() {
    super.initState();

    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _lensController = TextEditingController();
    _shutterController = TextEditingController();
    _apertureController = TextEditingController();
    _isoController = TextEditingController();
    _countryController = TextEditingController();
    _prefectureController = TextEditingController();
    _cityController = TextEditingController();
    _placeNameController = TextEditingController();
    _shopNameController = TextEditingController();
    _totalCostController = TextEditingController();
    _journalTitleController = TextEditingController();
    _journalContentController = TextEditingController();

    _exifDateTime = _parseExifDate(_getExif('Image DateTime'));

    // 先載入 friends 和 shopTypes，再載入資料
    _loadFriendsAndShopTypes().then((_) {
      if (widget.glimpseId != null) {
        appBarText = 'Edit';
        _loadExistingGlimpse(widget.glimpseId!);
      } else {
        appBarText = 'Create';
        _initFromExif();
      }
    });
  }

  Future<void> _loadExistingGlimpse(int id) async {
    final service = GlimpseService(DatabaseService.isar);
    final storedGlimpse = await service.getGlimpseWithLinks(id);

    if (storedGlimpse == null) {
      print('====== error, no glimpse for this glimpseId');
      return;
    }

    _glimpse = storedGlimpse;

    // 先把要用的 link 抽出來（service 內已 load 過）
    final receipt = _glimpse.receipt.value;
    final journal = _glimpse.journal.value;

    // 彙整 friends：receipt 與 journal 取聯集（以 id 去重）
    final Set<Id> friendIdSet = <Id>{};

    if (receipt != null) {
      for (final f in receipt.friends.whereType<Friend>()) {
        friendIdSet.add(f.id);
      }
    }
    if (journal != null) {
      for (final f in journal.friends.whereType<Friend>()) {
        friendIdSet.add(f.id);
      }
    }

    // 將 id 映回 _allFriends（只加找到的，避免 throw）
    final combinedSelectedFriends = <Friend>[];
    for (final fid in friendIdSet) {
      final match = _allFriends.where((af) => af.id == fid);
      if (match.isNotEmpty) combinedSelectedFriends.add(match.first);
    }

    setState(() {
      // ====== 基本欄位 ======
      _makeController.text = _glimpse.imageMake ?? '';
      _modelController.text = _glimpse.cameraModel ?? '';
      _lensController.text = _glimpse.lensModel ?? '';
      _shutterController.text = _glimpse.shutterSpeed ?? '';
      _apertureController.text = _glimpse.aperture ?? '';
      _isoController.text = _glimpse.iso ?? '';
      _exifDateTime = _glimpse.exifDateTime;
      _countryController.text = _glimpse.addressCountry ?? '';
      _prefectureController.text = _glimpse.addressPrefecture ?? '';
      _cityController.text = _glimpse.addressCity ?? '';
      _placeNameController.text = _glimpse.addressPlaceName ?? '';
      scannedImagePath = _glimpse.scannedImagePath ?? '';

      print('====== there is existing scannedImagePath');

      // ====== Receipt（若存在才填）======
      if (receipt != null) {
        _receipt = receipt;
        _shopNameController.text = _receipt?.shopName ?? '';
        _totalCostController.text =
        (_receipt?.totalCost != null) ? _receipt!.totalCost.toString() : '';

        final shopType = _receipt?.shopType.value;
        if (shopType != null) {
          try {
            _selectedShopType =
                _allShopTypes.firstWhere((type) => type.id == shopType.id);
          } catch (_) {
            _selectedShopType = null;
          }
        }
      }

      // ====== Journal（若存在才填）======
      _journalTitleController.text = journal?.title ?? '';
      _journalContentController.text = journal?.content ?? '';

      // ====== Friends：SSOT，用 receipt + journal 的聯集 ======
      _selectedFriends = combinedSelectedFriends;
    });
  }

  void _initFromExif() {
    _makeController.text = _getExif('Image Make') ?? '';
    _modelController.text = _getExif('Image Model') ?? '';
    _lensController.text = _getExif('EXIF LensModel') ?? '';
    _shutterController.text = _getExif('EXIF ExposureTime') ?? '';
    _apertureController.text = _getExif('EXIF FNumber') ?? '';
    _isoController.text = _getExif('EXIF ISOSpeedRatings') ?? '';
  }

  Future<void> _loadFriendsAndShopTypes() async {
    _allFriends = await DatabaseService.isar.friends.where().findAll();
    _allShopTypes = await DatabaseService.isar.shopTypes.where().findAll();
    if (mounted) setState(() {}); // 重建 widget
  }

  String? _getExif(String key) => widget.exifData[key]?.printable;

  DateTime? _parseExifDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      final parts = dateStr.split(' ');
      final date = parts[0].replaceAll(':', '-');
      final time = parts[1];
      return DateTime.parse('$date $time');
    } catch (_) {
      return null;
    }
  }

  Future<List<Friend>> getManagedFriends() async {
    final friendIds =
        _selectedFriends.where((f) => f.id != null).map((f) => f.id).toList();

    // 從資料庫中取得 Isar-managed Friend 實體
    final managedFriends = await DatabaseService.isar.friends
        .filter()
        .anyOf(friendIds, (q, int id) => q.idEqualTo(id))
        .findAll();

    return managedFriends;
  }

  Future<void> _insertGlimpse() async {
    _glimpse = Glimpse();
    final service = GlimpseService(DatabaseService.isar);

    _glimpse
      ..photoPath = widget.photoPath
      ..imageMake = _makeController.text
      ..cameraModel = _modelController.text
      ..lensModel = _lensController.text
      ..shutterSpeed = _shutterController.text
      ..aperture = _apertureController.text
      ..iso = _isoController.text
      ..exifDateTime = _exifDateTime
      ..addressCountry = _countryController.text
      ..addressPrefecture = _prefectureController.text
      ..addressCity = _cityController.text
      ..addressPlaceName = _placeNameController.text
      ..scannedImagePath = scannedImagePath
      ..createdAt = DateTime.now();

    await handleReceipt();
    await handleJournal();

    await service.insertGlimpse(glimpse: _glimpse, receipt: _receipt);
  }

  Future<void> _updateGlimpse() async {
    final service = GlimpseService(DatabaseService.isar);
    _glimpse
      ..photoPath = widget.photoPath
      ..imageMake = _makeController.text
      ..cameraModel = _modelController.text
      ..lensModel = _lensController.text
      ..shutterSpeed = _shutterController.text
      ..aperture = _apertureController.text
      ..iso = _isoController.text
      ..exifDateTime = _exifDateTime
      ..addressCountry = _countryController.text
      ..addressPrefecture = _prefectureController.text
      ..addressCity = _cityController.text
      ..addressPlaceName = _placeNameController.text
      ..scannedImagePath = scannedImagePath;

    await handleReceipt();
    await handleJournal();

    await service.updateGlimpseWithLinks(glimpse: _glimpse, receipt: _receipt);
  }

  Future<void> modifyExistingReceipt() async {
    _receipt
      ?..shopName = _shopNameController.text.trim()
      ..totalCost = int.tryParse(_totalCostController.text.trim()) ?? 0
      ..dateTime = _exifDateTime
      ..shopType.value = _selectedShopType;

    final managedFriends = await getManagedFriends();

    // 清空舊的並加入新的
    await _receipt!.friends.load();
    _receipt!.friends
      ..clear()
      ..addAll(managedFriends);
  }

  Future<void> createReceipt() async {
    _receipt = Receipt()
      ..shopName = _shopNameController.text.trim()
      ..totalCost = int.tryParse(_totalCostController.text.trim()) ?? 0
      ..dateTime = _exifDateTime
      ..shopType.value = _selectedShopType;

    final managedFriends = await getManagedFriends();

    _receipt!.friends.addAll(managedFriends);
  }

  Future<void> handleReceipt() async {
    if (hasReceiptInfo()) {
      if (_receipt != null) {
        await modifyExistingReceipt();
      } else {
        await createReceipt();
      }
    }
  }

  bool hasReceiptInfo() {
    return _shopNameController.text.trim().isNotEmpty ||
        (_totalCostController.text.trim().isNotEmpty &&
            int.tryParse(_totalCostController.text.trim()) != 0) ||
        _selectedShopType != null ||
        _selectedFriends.isNotEmpty;
  }

  /// insert or update
  Future<void> _saveGlimpse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.glimpseId == null) {
      await _insertGlimpse();
    } else {
      await _updateGlimpse();
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _onPressScanImage() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final resultPath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const EdgeDetectionPage()),
      );

      if (resultPath != null) {
        setState(() {
          scannedImagePath = resultPath;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('請授權儲存camera權限以使用此功能'),
          action: SnackBarAction(
            label: '前往設定',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  // ===== Journal: 判斷是否需要寫入 =====
  bool hasJournalInfo() {
    return _journalTitleController.text.trim().isNotEmpty ||
        _journalContentController.text.trim().isNotEmpty ||
        _selectedFriends.isNotEmpty;
  }

// ===== Journal: 既存更新 =====
  Future<void> modifyExistingJournal() async {
    if (_journal == null) return;

    _journal!
      ..title   = _journalTitleController.text.trim()
      ..content = _journalContentController.text.trim();

    final managedFriends = await getManagedFriends();

    // 以 DB 內的實體為準，先 load 再覆蓋
    await _journal!.friends.load();
    _journal!.friends
      ..clear()
      ..addAll(managedFriends);
  }

// ===== Journal: 新規建立 =====
  Future<void> createJournal() async {
    _journal = Journal()
      ..title     = _journalTitleController.text.trim()
      ..content   = _journalContentController.text.trim()
      ..createdAt = DateTime.now();

    final managedFriends = await getManagedFriends();
    _journal!.friends.addAll(managedFriends);

    // 連回 Glimpse（單向 Link）
    _glimpse.journal.value = _journal;
  }

// ===== Journal: 統一入口 =====
  Future<void> handleJournal() async {
    if (!hasJournalInfo()) {
      // 如果你想在「清空 journal 資訊」時把 Link 移除，可加上這段：
      // if (_glimpse.journal.value != null) {
      //   _glimpse.journal.value = null;
      // }
      return;
    }

    if (_journal != null) {
      await modifyExistingJournal();
    } else {
      await createJournal();
    }
  }


  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _lensController.dispose();
    _shutterController.dispose();
    _apertureController.dispose();
    _isoController.dispose();
    _countryController.dispose();
    _prefectureController.dispose();
    _cityController.dispose();
    _placeNameController.dispose();
    _shopNameController.dispose();
    _totalCostController.dispose();
    _journalTitleController.dispose();
    _journalContentController.dispose();
    super.dispose();
  }

  Widget _buildFriendChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: _allFriends.map((friend) {
        final isSelected = _isSelectedFriend(friend);
        return FilterChip(
          label: Text(friend.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!_isSelectedFriend(friend)) {
                  _selectedFriends.add(friend);
                }
              } else {
                _selectedFriends.removeWhere((f) => f.id == friend.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {required bool required}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (val) => val == null || val.isEmpty ? 'Required' : null
          : null,
    );
  }

  Widget journalInfoSection() {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Journal Title', _journalTitleController, required: false),
          const SizedBox(height: 12),
          // 長文輸入：固定高 + 可捲動
          SizedBox(
            height: screenHeight * 0.2,
            child: TextFormField(
              controller: _journalContentController,
              maxLines: null, // 多行
              expands: true,  // 讓它撐滿父容器高度
              decoration: const InputDecoration(
                labelText: 'Journal Content',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Friends (shared with Receipt)', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildFriendChips(), // ✅ 和 Receipt 共用同一組選擇狀態
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    LightSource neumorphicLightSource = LightSource.topLeft;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            // 自訂頂部
            Container(
              width: screenWidth,
              height: screenHeight * 0.1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    appBarText ?? '',
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontFamily: 'Questrial',
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              // <-- 把 Expanded 放到這裡
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.01, // 上 margin
                  bottom: screenHeight * 0.02, // 下 margin
                  left: screenWidth * 0.05, // 左 margin
                  right: screenWidth * 0.05, // 右 margin
                ),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    color: config.backGroundMainTheme,
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(screenWidth * 0.0168)),
                    intensity: 1,
                    depth: -1,
                    lightSource: neumorphicLightSource,
                  ),
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.0, // 上
                      bottom: screenHeight * 0.01, // 下
                      left: screenWidth * 0.02, // 左
                      right: screenWidth * 0.02, // 右
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          header1('Camera Info'),
                          cameraInfoSection(),
                          SizedBox(height: screenHeight * 0.05),
                          header1('Location Info'),
                          locationInfoSection(),

                          SizedBox(height: screenHeight * 0.05),
                          header1('Journal Info'),
                          journalInfoSection(),

                          SizedBox(height: screenHeight * 0.05),
                          header1('Receipt Info'),
                          receiptInfoSection(),

                          SizedBox(height: screenHeight * 0.05),
                          scannedImgSection(),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveGlimpse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  config.dashboardBackGroundMainTheme, // 按鈕背景色
                              foregroundColor: Colors.white, // 文字顏色
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text("Save Glimpse"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  bool _isSelectedFriend(Friend f) {
    // 以 id 比對，避免 Isar 物件參考不同導致 contains() 失效
    return _selectedFriends.any((sf) => sf.id == f.id);
  }

  Widget header1(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: screenHeight * 0.02,
        fontFamily: 'Questrial',
      ),
    );
  }

  Widget cameraInfoSection() {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03),
      child: Column(
        children: [
          _buildTextField('Make', _makeController, required: false),
          _buildTextField('Model', _modelController, required: false),
          _buildTextField('Lens', _lensController, required: false),
          _buildTextField('Shutter', _shutterController, required: false),
          _buildTextField('Aperture', _apertureController, required: false),
          _buildTextField('ISO', _isoController, required: false),
        ],
      ),
    );
  }

  Widget locationInfoSection() {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03),
      child: Column(
        children: [
          _buildTextField('Country', _countryController, required: false),
          _buildTextField('Prefecture', _prefectureController, required: false),
          _buildTextField('City', _cityController, required: false),
          _buildTextField('Place Name', _placeNameController, required: false),
        ],
      ),
    );
  }

  Widget receiptInfoSection() {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.03),
      child: Column(
        children: [
          _buildTextField('Shop Name', _shopNameController, required: false),
          _buildTextField('Total Cost (JPY)', _totalCostController,
              required: false),
          const SizedBox(height: 12),
          DropdownButtonFormField<ShopType>(
            value: _selectedShopType,
            items: _allShopTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedShopType = val;
              });
            },
            decoration: const InputDecoration(labelText: 'Shop Type'),
          ),
          const SizedBox(height: 12),
          const Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
          _buildFriendChips(), // ← 使用共用元件（與 Journal 同步）
        ],
      ),
    );
  }

  Widget scannedImgSection() {
    return SizedBox(
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.grey, width: 2),
      //     borderRadius: BorderRadius.circular((2))),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),
          Divider(thickness: screenHeight * 0.002),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.01),
            child: SizedBox(
              height: screenHeight * 0.05,
              width: screenWidth * 0.3,
              child: FittedBox(
                child: ElevatedButton(
                  onPressed: _onPressScanImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.dashboardBackGroundMainTheme,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                  child: const Text('掃描票卡'),
                ),
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          if (scannedImagePath.isNotEmpty) ...[
            Neumorphic(
              style: NeumorphicStyle(
                color: config.backGroundMainTheme,
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(screenWidth * 0.05),
                ),
                intensity: 1,
                depth: 1,
              ),
              child: Container(
                width: screenWidth*0.8,
                // 撐滿寬度
                height: screenHeight * 0.4,
                // 固定高度（或用 padding + constraints）
                color: config.dashboardBackGroundMainTheme.withOpacity(0.1),
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: screenWidth * 0.5,
                    maxHeight: screenHeight * 0.4,
                  ),
                  child: Image.file(
                    File(scannedImagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            )
          ],
          SizedBox(height: screenHeight * 0.05),
          Divider(thickness: screenHeight * 0.002),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }
}
