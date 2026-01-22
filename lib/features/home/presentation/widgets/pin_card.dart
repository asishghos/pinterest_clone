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
                      openModalSheet(context, widget.pin.src.medium);
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

  void openModalSheet(BuildContext context, String imgUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF2B2B2B), // Pinterest dark sheet
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),

                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const Spacer(),

                  Column(
                    children: [
                      ClipRRect(
                        child: Image.network(
                          imgUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "This Pin was inspired by your recent activity",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 24),

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
