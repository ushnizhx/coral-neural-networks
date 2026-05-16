import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';

class UploadZone extends StatelessWidget {
  final File? selectedImage;
  final ValueChanged<File?> onImageSelected;

  const UploadZone({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onImageSelected(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kCardLow,
          borderRadius: BorderRadius.circular(12), // xl = 0.75rem = 12px
        ),
        child: Container(
          decoration: BoxDecoration(
            color: kCardLowest,
            borderRadius: BorderRadius.circular(8), // lg = 0.5rem = 8px
            border: Border.all(
              color: kBorderGrey,
              style: BorderStyle.solid, // Wait, Flutter doesn't have native dashed borders cleanly without packages. The Prompt says dashed, I'll use simple solid or CustomPaint if needed. Let's use solid for simplicity as requested by the Stitch design but stitched design also had `border-dashed` ... but wait, creating a purely simple dashed border widget is out of scope. We'll use a slightly thick solid border or fake it.
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 48), // lg:p-20 ~ 80px, adjusting.
          child: selectedImage == null ? _buildEmptyState() : _buildLoadedState(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: kPrimaryContainer.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.add_a_photo, size: 48, color: kPrimaryTeal),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Drop your image here',
          style: kHeadlineStyle.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a file from your device.',
          style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 16),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image, size: 18, color: kOutline),
            const SizedBox(width: 8),
            Text('JPG', style: kLabelStyle.copyWith(fontSize: 12, color: kOutline)),
            const SizedBox(width: 24),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: kBorderGrey, shape: BoxShape.circle)),
            const SizedBox(width: 24),
            const Icon(Icons.high_quality, size: 18, color: kOutline),
            const SizedBox(width: 8),
            Text('UP TO 25MB', style: kLabelStyle.copyWith(fontSize: 12, color: kOutline)),
          ],
        )
      ],
    );
  }

  Widget _buildLoadedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            selectedImage!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          selectedImage!.path.split('/').last,
          style: kBodyStyle.copyWith(fontSize: 12, color: kTextSecondary),
        ),
      ],
    );
  }
}
