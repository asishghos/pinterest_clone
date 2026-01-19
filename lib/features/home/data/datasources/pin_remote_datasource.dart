import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/pin_model.dart';

class PinRemoteDataSource {
  final DioClient dioClient;

  PinRemoteDataSource(this.dioClient);

  Future<List<PinModel>> getCuratedPins({
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    try {
      final response = await dioClient.get(
        ApiConstants.curatedPhotos,
        queryParameters: {'page': page, 'per_page': perPage},
      );

      final photos = response.data['photos'] as List;
      return photos.map((json) => PinModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch curated pins: $e');
    }
  }

  Future<List<PinModel>> searchPins(
    String query, {
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    try {
      final response = await dioClient.get(
        ApiConstants.searchPhotos,
        queryParameters: {'query': query, 'page': page, 'per_page': perPage},
      );

      final photos = response.data['photos'] as List;
      return photos.map((json) => PinModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search pins: $e');
    }
  }

  Future<PinModel> getPinById(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.photoDetail}/$id');
      return PinModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch pin details: $e');
    }
  }
}
