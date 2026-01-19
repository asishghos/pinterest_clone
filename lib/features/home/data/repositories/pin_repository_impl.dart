import 'package:pinterest/features/home/data/datasources/pin_remote_datasource.dart';

import '../../domain/entities/pin.dart';
import '../../domain/repositories/pin_repository.dart';

class PinRepositoryImpl implements PinRepository {
  final PinRemoteDataSource remoteDataSource;

  PinRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Pin>> getCuratedPins({int page = 1, int perPage = 30}) async {
    return await remoteDataSource.getCuratedPins(page: page, perPage: perPage);
  }

  @override
  Future<List<Pin>> searchPins(
    String query, {
    int page = 1,
    int perPage = 30,
  }) async {
    return await remoteDataSource.searchPins(
      query,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<Pin> getPinById(int id) async {
    return await remoteDataSource.getPinById(id);
  }
}
