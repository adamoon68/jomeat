import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';

class AdminMenuScreen extends StatefulWidget {
  final FoodItem? initialFood;

  const AdminMenuScreen({super.key, this.initialFood});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _availability = 'Available';
  String? _selectedImagePath;
  FoodItem? _editingFood;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initialFood = widget.initialFood;
    if (initialFood != null) {
      _setEditingFood(initialFood);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _prepController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Food Image',
          toolbarColor: const Color(0xFFE66A2C),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Food Image'),
      ],
    );

    if (croppedFile != null) {
      setState(() => _selectedImagePath = croppedFile.path);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _priceController.clear();
    _prepController.clear();
    setState(() {
      _availability = 'Available';
      _selectedImagePath = null;
      _editingFood = null;
    });
  }

  void _setEditingFood(FoodItem food) {
    _nameController.text = food.name;
    _descriptionController.text = food.description;
    _categoryController.text = food.category;
    _priceController.text = food.price.toStringAsFixed(2);
    _prepController.text = food.preparationTime.toString();
    _availability = food.availability;
    _selectedImagePath = null;
    _editingFood = food;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final editingFood = _editingFood;
    if (editingFood == null && _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a food image')),
      );
      return;
    }

    setState(() => _saving = true);
    final result = editingFood == null
        ? await ApiService.adminAddFood(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            price: _priceController.text.trim(),
            preparationTime: _prepController.text.trim(),
            availability: _availability,
            imagePath: _selectedImagePath!,
          )
        : await ApiService.adminUpdateFood(
            foodId: editingFood.foodId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _categoryController.text.trim(),
            price: _priceController.text.trim(),
            preparationTime: _prepController.text.trim(),
            availability: _availability,
            imagePath: _selectedImagePath,
          );
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Save finished')),
    );

    if (result['success'] == true) {
      _clearForm();
      if (editingFood != null) {
        Navigator.pop(context, true);
      }
    }
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  Widget _buildImagePicker() {
    final imagePath = _selectedImagePath;
    final editingFood = _editingFood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImagePreview(imagePath, editingFood),
        ),
        const SizedBox(height: 10),
        CustomButton(
          text: imagePath == null && editingFood == null
              ? 'Upload Image'
              : 'Change Image',
          icon: Icons.upload_file,
          onPressed: _pickAndCropImage,
        ),
      ],
    );
  }

  Widget _buildImagePreview(String? imagePath, FoodItem? editingFood) {
    if (imagePath != null) {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      );
    }

    if (editingFood != null && editingFood.imageName.isNotEmpty) {
      return Image.network(
        AppConfig.foodImageUrl(editingFood.imageName),
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildEmptyImagePreview(),
      );
    }

    return _buildEmptyImagePreview();
  }

  Widget _buildEmptyImagePreview() {
    return Container(
      width: double.infinity,
      height: 180,
      color: const Color(0xFFFFE3D2),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 48, color: Color(0xFFE66A2C)),
          SizedBox(height: 8),
          Text('Upload a food image'),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final editingFood = _editingFood;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editingFood == null ? 'Create New Food Item' : 'Edit Food Item',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildImagePicker(),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _prepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prep Minutes',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final minutes = int.tryParse(value ?? '');
                      if (minutes == null || minutes < 0) {
                        return 'Invalid time';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _availability,
              decoration: const InputDecoration(
                labelText: 'Availability',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(
                  value: 'Unavailable',
                  child: Text('Unavailable'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _availability = value ?? 'Available'),
            ),
            const SizedBox(height: 16),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: editingFood == null
                              ? 'Create Item'
                              : 'Update Item',
                          icon: editingFood == null
                              ? Icons.add_box
                              : Icons.save,
                          onPressed: _save,
                        ),
                      ),
                      if (editingFood != null) ...[
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.close),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                          ),
                        ),
                      ],
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingFood == null ? 'Create Item' : 'Edit Item'),
      ),
      body: ListView(children: [_buildForm()]),
    );
  }
}
