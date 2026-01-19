class ApiConstants {
  // Pexels API
  static const String pexelsApiKey =
      'XYPRym0JNfKnulzt1uWafmswBhUWXXoGa8WELcpYqbrxqnuR2DzCCPTJ';
  static const String pexelsBaseUrl = 'https://api.pexels.com/v1';

  // Endpoints
  static const String curatedPhotos = '/curated';
  static const String searchPhotos = '/search';
  static const String photoDetail = '/photos';

  // Pagination
  static const int defaultPerPage = 30;
  static const int maxPerPage = 80;
}
