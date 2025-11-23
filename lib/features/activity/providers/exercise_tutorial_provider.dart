import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gainers/features/activity/data/models/fitness_video_model.dart';

final youtubeApiProvider = Provider<YoutubeAPI>((ref) {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? '';
  return YoutubeAPI(apiKey, maxResults: 15, type: 'video');
});

final exerciseVideoProvider = FutureProvider.family<List<FitnessVideo>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    final api = ref.read(youtubeApiProvider);

    final searchString = '$query fitness tutorial';

    final results = await api.search(searchString);

    return results.map((item) => FitnessVideo.fromApi(item)).toList();
  },
);
