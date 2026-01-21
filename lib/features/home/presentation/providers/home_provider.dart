import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pinterest/features/home/data/datasources/pin_remote_datasource.dart';
import 'package:pinterest/features/home/data/repositories/pin_repository_impl.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';

// Providers
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final pinRemoteDataSourceProvider = Provider<PinRemoteDataSource>((ref) {
  return PinRemoteDataSource(ref.watch(dioClientProvider));
});

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return PinRepositoryImpl(ref.watch(pinRemoteDataSourceProvider));
});

// Home State
class HomeState {
  final List<Pin> pins;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  HomeState({
    this.pins = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  HomeState copyWith({
    List<Pin>? pins,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return HomeState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Home Provider
class HomeNotifier extends StateNotifier<HomeState> {
  final PinRepository repository;

  HomeNotifier(this.repository) : super(HomeState());

  Future<void> loadPins({int page = 1, bool append = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newPins = await repository.getCuratedPins(page: page);

      state = state.copyWith(
        pins: append ? [...state.pins, ...newPins] : newPins,
        isLoading: false,
        currentPage: page,
        hasMore: newPins.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMorePins() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPins = await repository.getCuratedPins(page: nextPage);

      final existingIds = state.pins.map((e) => e.id).toSet();

      final uniquePins = newPins
          .where((pin) => !existingIds.contains(pin.id))
          .toList();

      state = state.copyWith(
        pins: [...state.pins, ...uniquePins],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: uniquePins.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = HomeState();
    await loadPins(page: Random().nextInt(100) + 1);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(pinRepositoryProvider));
});
