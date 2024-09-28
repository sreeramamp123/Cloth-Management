import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';  // For handling file
import 'package:flutter_colorpicker/flutter_colorpicker.dart';  // For color picker

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController();
  File? _pickedImage;  // To store the selected image
  final ImagePicker _picker = ImagePicker();  // For image picking
  Color _selectedColor = Colors.white;  // Default color picker value

  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedProduct;

  bool _isAvailableForTrade = false;  // Checkbox for Trade availability
  bool _isAvailableForDonate = false;  // Checkbox for Donation availability

  final List<String> categories = ['Clothing', 'Accessories'];
  final Map<String, List<String>> clothingSubCategories = {
    'Indian-wear': ['Kurtha', 'Dhoti', 'Saree', 'Chudidar'],
    'Western-wear': ['Pants', 'Shirts', 'T-Shirts', 'Trousers', 'Blazers', 'Tops', 'Party-wear'],
    'Inner-wear': ['Kaccha', 'Lingeries'],
    'Foot-wear': ['Shoes', 'Slippers', 'Heels']
  };

  final List<String> accessoryProducts = ['Bags', 'Watches', 'Jewelry'];

  // Function to pick image from camera or gallery
  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick an image from the selected source
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the URL
  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
        .child('${DateTime.now().toIso8601String()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  // Function to show a SnackBar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Open the color picker dialog
  Future<void> _showColorPicker() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Select'),
            ),
          ],
        );
      },
    );
  }

  // Submit the product details and upload the image
  void _submitData() async {
    final enteredSize = _sizeController.text;

    if (_selectedCategory == null || _selectedSubCategory == null || _selectedProduct == null || enteredSize.isEmpty || _pickedImage == null) {
      _showSnackBar("Please fill all fields and upload an image.", Colors.red);
      return;
    }

    try {
      // Upload image and get the URL
      final imageUrl = await _uploadImage(_pickedImage!);

      // Store the product details in Firestore with the image URL
      await FirebaseFirestore.instance.collection('products').add({
        'category': _selectedCategory,
        'subCategory': _selectedSubCategory,
        'product': _selectedProduct,
        'color': _selectedColor.toString(),  // Save the selected color as a string
        'size': enteredSize,
        'imageUrl': imageUrl,  // Add image URL
        'isAvailableForTrade': _isAvailableForTrade,  // Store trade availability
        'isAvailableForDonate': _isAvailableForDonate,  // Store donate availability
        'createdAt': Timestamp.now(),
      });

      _showSnackBar("Product Added Successfully to Wardrobe", Colors.green);
      Navigator.of(context).pop();  // Close the form after submitting
    } catch (error) {
      _showSnackBar("Couldn't add Product. Try again", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSubCategory = null;  // Reset sub-category when category changes
                  _selectedProduct = null;      // Reset product when category changes
                });
              },
            ),
            if (_selectedCategory == 'Clothing') ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Sub-Category'),
                value: _selectedSubCategory,
                items: clothingSubCategories.keys.map((subCategory) {
                  return DropdownMenuItem(
                    value: subCategory,
                    child: Text(subCategory),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value;
                    _selectedProduct = null;  // Reset product when sub-category changes
                  });
                },
              ),
              if (_selectedSubCategory != null)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Product Name'),
                  value: _selectedProduct,
                  items: clothingSubCategories[_selectedSubCategory]!.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(product),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                    });
                  },
                ),
            ],
            TextButton.icon(
              onPressed: _showColorPicker,
              icon: Icon(Icons.color_lens),
              label: Text('Pick Color'),
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: _selectedColor,
                border: Border.all(width: 1),
              ),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Size'),
              controller: _sizeController,
              onSubmitted: (_) => _submitData(),
            ),
            SwitchListTile(
              title: Text('Available for Trade'),
              value: _isAvailableForTrade,
              onChanged: (value) {
                setState(() {
                  _isAvailableForTrade = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Available for Donate'),
              value: _isAvailableForDonate,
              onChanged: (value) {
                setState(() {
                  _isAvailableForDonate = value;
                });
              },
            ),
            SizedBox(height: 20),
            _pickedImage != null
                ? Image.file(
                    _pickedImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Text('No image selected'),
            TextButton.icon(
              onPressed: _showImageSourceActionSheet,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
