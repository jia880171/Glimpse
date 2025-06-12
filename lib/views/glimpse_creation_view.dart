import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:glimpse/models/glimpse.dart';
import 'package:glimpse/services/database_service.dart';

class GlimpseCreationView extends StatefulWidget {
  final String photoPath;
  final Map<String?, IfdTag> exifData;

  const GlimpseCreationView({
    Key? key,
    required this.photoPath,
    required this.exifData,
  }) : super(key: key);

  @override
  State<GlimpseCreationView> createState() => _GlimpseCreationViewState();
}

class _GlimpseCreationViewState extends State<GlimpseCreationView> {
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

  DateTime? _exifDateTime;

  @override
  void initState() {
    super.initState();

    _makeController = TextEditingController(text: _getExif('Image Make'));
    _modelController = TextEditingController(text: _getExif('Image Model'));
    _lensController = TextEditingController(text: _getExif('EXIF LensModel'));
    _shutterController =
        TextEditingController(text: _getExif('EXIF ExposureTime'));
    _apertureController = TextEditingController(text: _getExif('EXIF FNumber'));
    _isoController =
        TextEditingController(text: _getExif('EXIF ISOSpeedRatings'));
    _exifDateTime = _parseExifDate(_getExif('Image DateTime'));

    _countryController = TextEditingController();
    _prefectureController = TextEditingController();
    _cityController = TextEditingController();
    _placeNameController = TextEditingController();
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

  Future<void> _saveGlimpse() async {
    if (!_formKey.currentState!.validate()) return;

    final newGlimpse = Glimpse()
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
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.isar.glimpses.put(newGlimpse);
    });

    if (mounted) Navigator.pop(context);
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
