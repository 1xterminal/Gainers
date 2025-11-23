import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gainers/features/activity/data/models/fitness_video_model.dart';
import 'package:gainers/features/activity/providers/exercise_tutorial_provider.dart';

class ExerciseTutorialScreen extends ConsumerStatefulWidget {
  const ExerciseTutorialScreen({super.key});

  @override
  ConsumerState<ExerciseTutorialScreen> createState() =>
      _ExerciseTutorialScreenState();
}

class _ExerciseTutorialScreenState
    extends ConsumerState<ExerciseTutorialScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _currentQuery = '';

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _currentQuery = _searchController.text;
      });
    }
  }

  Future<void> _launchVideo(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch video')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncVideos = ref.watch(exerciseVideoProvider(_currentQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness & Tutorials')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 13,
              right: 13,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.blueGrey,
                        offset: Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for exercises',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.lightBlue.shade800,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.lightBlue.shade800,
                        ),
                        onPressed: _performSearch,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          Expanded(
            child: asyncVideos.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return Center(
                    child: Text(
                      'Search to find videos',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoCard(video);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(FitnessVideo video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueGrey,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchVideo(video.videoUrl),
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (video.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(5),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    video.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    video.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    video.channelName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
