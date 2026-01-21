import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../domain/entities/pin.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PinCard extends StatefulWidget {
  final Pin pin;
  final String heroTag;

  const PinCard({super.key, required this.pin, required this.heroTag});

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/pin/${widget.pin.id}',
          extra: {'imageUrl': widget.pin.src.large, 'heroTag': widget.heroTag},
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Hero(
                      tag: widget.heroTag,
                      child: CachedNetworkImage(
                        imageUrl: widget.pin.src.medium,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: _parseColor(widget.pin.avgColor)),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.0),
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_isHovered)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          child: InkWell(
                            onTap: () {
                              // Handle save action
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isHovered)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                widget.pin.photographer[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                widget.pin.photographer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Text
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _limitLetters(widget.pin.alt, 20),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '...',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menu Icon
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      openModalSheet(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant, // dark surface
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              _sheetItem(
                icon: HugeIcons.strokeRoundedPin,
                title: 'Save',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _sheetItem(
                icon: HugeIcons.strokeRoundedShare08,
                title: 'Share',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _sheetItem(
                icon: HugeIcons.strokeRoundedDownload01,
                title: 'Download image',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _sheetItem(
                icon: HugeIcons.strokeRoundedEye,
                title: 'See less like this',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _sheetItem(
                icon: HugeIcons.strokeRoundedFavourite,
                title: 'See more like this',
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _sheetItem(
                icon: HugeIcons.strokeRoundedCancelCircle,
                title: 'Report Pin',
                isDanger: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetHandle() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              color: AppColors.iconPrimary,
              size: 32,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _sheetItem({
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      leading: HugeIcon(icon: icon, color: AppColors.iconPrimary, size: 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 15),
          ),
          ?isDanger == true
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'This goes against Pinterest\'s community guidelines',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              : null,
        ],
      ),
      onTap: onTap,
    );
  }

  String _limitLetters(String text, int maxLetters) {
    final trimmed = text.trim();

    if (trimmed.length <= maxLetters) return trimmed;

    return trimmed.substring(0, maxLetters);
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey[300]!;
    }
  }
}
