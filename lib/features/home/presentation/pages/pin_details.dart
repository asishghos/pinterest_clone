import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:pinterest/features/home/domain/entities/pin.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PinDetailPage extends StatefulWidget {
  Pin pin;

  PinDetailPage({super.key, required this.pin});

  @override
  State<PinDetailPage> createState() => _PinDetailPageState();
}

class _PinDetailPageState extends State<PinDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: widget.pin.src.original,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 500,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedFavourite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Random().nextInt(1000).toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedComment03,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Random().nextInt(100).toString(),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          Share.share(
                            "Check this out! 🚀\n${widget.pin.src.original}",
                          );
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedShare08,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          showOptionsBottomSheet(
                            context,
                            imageUrl: widget.pin.src.original,
                            userName: widget.pin.photographer,
                            pinId: widget.pin.id.toString(),
                          );
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMoreHorizontal,
                          size: 32,
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          developer.log('cka');

                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          final userId = user.uid;

                          final itemData = {
                            "imageUrl": widget.pin.src.original,
                            "createdAt": DateTime.now(),
                          };

                          final docRef = FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId);

                          await docRef.set({
                            "savedItems": FieldValue.arrayUnion([itemData]),
                          }, SetOptions(merge: true));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item saved successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),

                        child: Text(
                          'Save',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: widget.pin.photographerUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.pin.photographer,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.pin.alt,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'More to explore',
                  style: GoogleFonts.roboto(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Related Pins Grid
            FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

void showOptionsBottomSheet(
  BuildContext context, {
  required String imageUrl,
  required String userName,
  String? pinId,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => OptionsBottomSheet(
      imageUrl: imageUrl,
      userName: userName,
      pinId: pinId,
    ),
  );
}

class OptionsBottomSheet extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String? pinId;

  const OptionsBottomSheet({
    super.key,
    required this.imageUrl,
    required this.userName,
    this.pinId,
  });

  Future<void> _copyLink(BuildContext context) async {
    try {
      final link = pinId != null ? 'https://yourapp.com/pin/$pinId' : imageUrl;

      await Clipboard.setData(ClipboardData(text: link));

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.black87,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      Navigator.pop(context);

      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Downloading image...'),
              ],
            ),
            duration: Duration(seconds: 30),
            backgroundColor: Colors.black87,
          ),
        );
      }

      // Request storage permission
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        PermissionStatus status;

        if (sdkInt >= 33) {
          // Android 13+
          status = await Permission.photos.request();
        } else if (sdkInt >= 30) {
          // Android 11–12
          status = await Permission.manageExternalStorage.request();
        } else {
          // Android 10 and below
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission required'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get the downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        // Generate filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'pinterest_image_$timestamp.jpg';
        final filePath = '${directory!.path}/$fileName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image saved to ${Platform.isAndroid ? 'Downloads' : 'Documents'}',
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        developer.log('Failed to download image: ${response.statusCode}');
        throw Exception('Failed to download image');
      }
    } catch (e) {
      if (context.mounted) {
        developer.log('Failed to download image: ${e}');

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.iconPrimary, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Options',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            _buildOption(
              context,
              title: 'Follow $userName',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Following $userName'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'Copy link',
              onTap: () => _copyLink(context),
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'Download image',
              onTap: () => _downloadImage(context),
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'Add to collage',
              onTap: () {
                Navigator.pop(context);
                // Implement add to collage functionality
              },
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'See more like this',
              onTap: () {
                Navigator.pop(context);
                // Implement see more functionality
              },
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'See less like this',
              onTap: () {
                Navigator.pop(context);
                // Implement see less functionality
              },
              isLast: true,
            ),
            _buildOption(
              context,
              title: 'Report Pin',
              subtitle: "This goes against Pinterest's Community Guidelines",
              onTap: () {
                Navigator.pop(context);
              },
              isLast: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(bottom: BorderSide(color: AppColors.textPrimary))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
