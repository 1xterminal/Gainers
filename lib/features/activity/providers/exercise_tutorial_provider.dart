import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gainers/features/activity/data/models/fitness_video_model.dart';

//provider to get youtube api
final youtubeApiProvider = Provider<YoutubeAPI>((ref) {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception('YOUTUBE_API_KEY is missing in .env');
  }
  return YoutubeAPI(apiKey, maxResults: 15, type: 'video');
});

//provider to get exercise video based on search query
final exerciseVideoProvider = FutureProvider.family<List<FitnessVideo>, String>(
  (ref, query) async {
    final api = ref.read(youtubeApiProvider);

    String searchString;

    if (query.isEmpty) {
      searchString = 'popular fitness workout exercises';
    } else {
      searchString = '$query fitness tutorial';
    }

    final results = await api.search(searchString);

    return results.map((item) => FitnessVideo.fromApi(item)).toList();
  },
);
