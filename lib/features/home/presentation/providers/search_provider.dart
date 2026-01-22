import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pinterest/features/home/presentation/providers/home_provider.dart';
import '../../../home/domain/entities/pin.dart';
import '../../../home/domain/repositories/pin_repository.dart';

class SearchState {
  final List<Pin> pins;
  final bool isLoading;
  final String? error;
  final String query;

  SearchState({
    this.pins = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<Pin>? pins,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      pins: pins ?? this.pins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final PinRepository repository;

  SearchNotifier(this.repository) : super(SearchState());

  Future<void> searchPins(
    String query, {
    int page = 1,
    int perPage = 30,
  }) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      final pins = await repository.searchPins(
        query,
        page: page,
        perPage: perPage,
      );
      state = state.copyWith(pins: pins, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearSearch() {
    state = SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier(ref.watch(pinRepositoryProvider));
});
