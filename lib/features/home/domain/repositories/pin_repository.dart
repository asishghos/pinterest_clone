import '../entities/pin.dart';

abstract class PinRepository {
  Future<List<Pin>> getCuratedPins({int page = 1, int perPage = 30});
  Future<List<Pin>> searchPins(String query, {int page = 1, int perPage = 30});
  Future<Pin> getPinById(int id);
}
