import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pinterest/core/constants/app_colors.dart';
import 'package:pinterest/features/home/domain/entities/pin.dart';
import 'package:pinterest/features/home/presentation/providers/home_provider.dart';
import '../providers/search_provider.dart';
import '../../../home/presentation/widgets/pin_card.dart';

// Categories for carousel
final carouselCategories = [
  {
    'title': 'Little luxuries in life',
    'subtitle': 'Magical moments',
    'keyword': 'luxury lifestyle',
  },
  {
    'title': 'Cozy home vibes',
    'subtitle': 'Interior inspiration',
    'keyword': 'home decor',
  },
  {'title': 'Fashion trends', 'subtitle': 'Style guide', 'keyword': 'fashion'},
  {
    'title': 'Nature escapes',
    'subtitle': 'Outdoor adventure',
    'keyword': 'nature',
  },
  {
    'title': 'Artistic expressions',
    'subtitle': 'Creative ideas',
    'keyword': 'art',
  },
  {
    'title': 'Delicious recipes',
    'subtitle': 'Food inspiration',
    'keyword': 'food',
  },
  {
    'title': 'Fitness goals',
    'subtitle': 'Healthy living',
    'keyword': 'fitness',
  },
];

// Featured boards topics
final featuredBoardsTopics = [
  {'title': 'Escape to Indian hills', 'keyword': 'indian hills'},
  {'title': 'Yoga mornings aesthetic', 'keyword': 'yoga'},
  {'title': 'Minimalist fashion', 'keyword': 'minimalist fashion'},
  {'title': 'Home decor ideas', 'keyword': 'home decor'},
  {'title': 'Food photography', 'keyword': 'food photography'},
  {'title': 'Travel destinations', 'keyword': 'travel'},
  {'title': 'Modern architecture', 'keyword': 'architecture'},
  {'title': 'Vintage aesthetics', 'keyword': 'vintage'},
];

// Ideas for you topics
final ideasForYouTopics = [
  'Mens photoshoot poses',
  'Wedding decorations',
  'DIY crafts',
  'Bedroom makeover',
  'Street style fashion',
  'Dessert recipes',
];

// Providers for carousel items
final carouselPinsProvider = FutureProvider.family<List<Pin>, String>((
  ref,
  keyword,
) async {
  final repository = ref.watch(pinRepositoryProvider);
  try {
    final pins = await repository.searchPins(keyword, perPage: 1);
    return pins.take(1).toList();
  } catch (e) {
    return [];
  }
});

// Providers for featured boards
final featuredBoardPinsProvider = FutureProvider.family<List<Pin>, String>((
  ref,
  keyword,
) async {
  final repository = ref.watch(pinRepositoryProvider);
  try {
    final pins = await repository.searchPins(keyword, perPage: 3);
    return pins.take(5).toList();
  } catch (e) {
    return [];
  }
});

// Provider for ideas for you
final ideasPinsProvider = FutureProvider.family<List<Pin>, String>((
  ref,
  keyword,
) async {
  final repository = ref.watch(pinRepositoryProvider);
  try {
    final pins = await repository.searchPins(keyword, perPage: 5);
    return pins.take(10).toList();
  } catch (e) {
    return [];
  }
});

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // Preload carousel data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var category in carouselCategories) {
        ref.read(carouselPinsProvider(category['keyword']!));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).searchPins(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF3C3C3C)),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search for ideas',
              hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF8E8E93),
                size: 24,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        size: 20,
                        color: Color(0xFF8E8E93),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clearSearch();
                        setState(() {});
                      },
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (value) => setState(() {}),
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: searchState.query.isEmpty
          ? _buildIdeasSection()
          : searchState.isLoading && searchState.pins.isEmpty
          ? _buildLoadingGrid()
          : searchState.pins.isEmpty
          ? _buildEmptyState()
          : _buildResultsGrid(searchState),
    );
  }

  Widget _buildIdeasSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCarousel(),
          const SizedBox(height: 24),
          _buildFeaturedBoards(),
          const SizedBox(height: 24),
          ...ideasForYouTopics.map(
            (topic) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildIdeasForYou(topic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: carouselCategories.length,
            itemBuilder: (context, index) {
              final category = carouselCategories[index];
              final pinsAsync = ref.watch(
                carouselPinsProvider(category['keyword']!),
              );

              return pinsAsync.when(
                data: (pins) {
                  final imageUrl = pins.isNotEmpty ? pins.first.url : null;

                  return GestureDetector(
                    onTap: () => _performSearch(category['keyword']!),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[900],
                        image: imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['subtitle']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => _buildCarouselPlaceholder(category),
                error: (_, __) => _buildCarouselPlaceholder(category),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselCategories.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselPlaceholder(Map<String, String> category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[900],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category['subtitle']!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBoards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Explore featured boards',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ideas you might like',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: featuredBoardsTopics.length,
            itemBuilder: (context, index) {
              final board = featuredBoardsTopics[index];
              final pinsAsync = ref.watch(
                featuredBoardPinsProvider(board['keyword']!),
              );

              return pinsAsync.when(
                data: (pins) {
                  final imageUrl = pins.isNotEmpty ? pins.first.url : null;
                  final pinCount = pins.length;

                  return GestureDetector(
                    onTap: () => _performSearch(board['keyword']!),
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageUrl != null
                                ? Image.network(
                                    imageUrl,
                                    height: 180,
                                    width: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildBoardPlaceholder();
                                    },
                                  )
                                : _buildBoardPlaceholder(),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            board['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Pinterest',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.red,
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$pinCount Pins',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => _buildBoardLoadingItem(board['title']!),
                error: (_, __) => _buildBoardLoadingItem(board['title']!),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBoardPlaceholder() {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildBoardLoadingItem(String title) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasForYou(String topic) {
    final pinsAsync = ref.watch(ideasPinsProvider(topic));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            topic,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        pinsAsync.when(
          data: (pins) {
            if (pins.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pins.length,
                itemBuilder: (context, index) {
                  final pin = pins[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to pin detail
                      context.push('/pin/${pin.id}');
                    },
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pin.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[800],
                  ),
                );
              },
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildResultsGrid(SearchState searchState) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(12),
      itemCount: searchState.pins.length,
      itemBuilder: (context, index) {
        final pin = searchState.pins[index];
        return PinCard(pin: pin, heroTag: 'search-pin-${pin.id}-$index');
      },
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 200 + (index % 3) * 50,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
