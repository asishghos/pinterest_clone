import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/home_provider.dart';
import '../widgets/pin_card.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/app_colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = ref.read(homeProvider);

      debugPrint("HOME INIT → pins count: ${homeState.pins.length}");

      if (homeState.pins.isEmpty) {
        debugPrint("LOADING INITIAL PINS...");
        ref
            .read(homeProvider.notifier)
            .loadPins(page: Random().nextInt(100) + 1);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 500 && !_isFetchingMore) {
      debugPrint("SCROLL → Loading more pins...");
      _isFetchingMore = true;

      ref.read(homeProvider.notifier).loadMorePins().then((_) {
        _isFetchingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(
              "For You",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            HugeIcon(
              icon: HugeIcons.strokeRoundedAiEditing,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          debugPrint("REFRESH → Reloading pins...");
          await ref.read(homeProvider.notifier).refresh();
        },
        color: AppColors.primary,

        child: homeState.isLoading && homeState.pins.isEmpty
            ? _buildShimmerLoading()
            : homeState.error != null && homeState.pins.isEmpty
            ? _buildErrorWidget(homeState.error!)
            : _buildMasonryGrid(homeState),
      ),
    );
  }

  Widget _buildMasonryGrid(HomeState state) {
    return MasonryGridView.count(
      controller: _scrollController,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(12),
      itemCount: state.pins.length + (state.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= state.pins.length) {
          return _buildShimmerItem(2);
        }

        final pin = state.pins[index];
        developer.log('Building pin card for pin id: ${pin.id}');
        return PinCard(pin: pin, heroTag: 'pin-${pin.id}-$index');
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.all(12),
            itemCount: 10,
            // We use index to vary heights to get that staggered look
            itemBuilder: (context, index) => _buildShimmerItem(index),
          ),
        ),
      ],
    );
  }

  // Shimmer for the grid items with varying heights
  Widget _buildShimmerItem(int index) {
    return Container(
      height: (index % 3 == 0) ? 200 : 280,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Wrap this with Shimmer.fromColors
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // Widget _buildShimmerItem() {
  //   final heights = [200.0, 250.0, 300.0, 350.0];
  //   final height = heights[DateTime.now().millisecond % heights.length];

  //   return Container(
  //     height: height,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300],
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(16),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref
                .read(homeProvider.notifier)
                .loadPins(page: Random().nextInt(100) + 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
