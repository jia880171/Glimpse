import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';
import 'package:glimpse/views/Edge_detection_view.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/friend.dart';
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

  DateTime? _exifDateTime;
  String scannedImagePath = '';

  late Glimpse _glimpse;
  Receipt? _receipt;
  ShopType? _selectedShopType;
  List<Friend> _allFriends = [];
  List<Friend> _selectedFriends = [];
  List<ShopType> _allShopTypes = [];

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

    _exifDateTime = _parseExifDate(_getExif('Image DateTime'));

    // 先載入 friends 和 shopTypes，再載入資料
    _loadFriendsAndShopTypes().then((_) {
      if (widget.glimpseId != null) {
        _loadExistingGlimpse(widget.glimpseId!);
      } else {
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

    setState(() {
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

      if (_glimpse.receipt.value == null) {
        return;
      } else {
        _receipt = _glimpse.receipt.value!;
        _shopNameController.text = _receipt?.shopName ?? '';
        _totalCostController.text = ((_receipt?.totalCost != null)
            ? _receipt?.totalCost.toString()
            : '')!;

        final shopType = _receipt?.shopType.value;
        if (shopType != null) {
          try {
            _selectedShopType =
                _allShopTypes.firstWhere((type) => type.id == shopType.id);
          } catch (e) {
            _selectedShopType = null;
          }
        }

        _selectedFriends = _receipt!.friends
            .whereType<Friend>()
            .map((f) => _allFriends.firstWhere((af) => af.id == f.id))
            .toList();
      }
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
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Glimpse")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Photo: ${widget.photoPath}",
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              _buildTextField('Make', _makeController, required: false),
              _buildTextField('Model', _modelController, required: false),
              _buildTextField('Lens', _lensController, required: false),
              _buildTextField('Shutter', _shutterController, required: false),
              _buildTextField('Aperture', _apertureController, required: false),
              _buildTextField('ISO', _isoController, required: false),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Address Info',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Country', _countryController, required: false),
              _buildTextField('Prefecture', _prefectureController,
                  required: false),
              _buildTextField('City', _cityController, required: false),
              _buildTextField('Place Name', _placeNameController,
                  required: false),
              const Divider(),
              const Text('Receipt Info',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildTextField('Shop Name', _shopNameController,
                  required: false),
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
              const Text('Friends',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _allFriends.map((friend) {
                  final isSelected = _selectedFriends.contains(friend);
                  return FilterChip(
                    label: Text(friend.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        isSelected
                            ? _selectedFriends.remove(friend)
                            : _selectedFriends.add(friend);
                      });
                    },
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.camera.request();

                  if (status.isGranted) {
                    final resultPath = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EdgeDetectionPage()),
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
                },
                child: const Text('測試 edge_detection'),
              ),
              Text(scannedImagePath),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGlimpse,
                child: const Text("Save Glimpse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
