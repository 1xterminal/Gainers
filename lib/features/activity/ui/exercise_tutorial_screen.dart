import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gainers/features/activity/data/models/fitness_video_model.dart';
import 'package:gainers/features/activity/providers/exercise_tutorial_provider.dart';
import 'package:gainers/core/theme/app_theme.dart';

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

  //perform search
  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _currentQuery = _searchController.text;
      });
    }
  }

  //opens video url in external application
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
    //watch the provider with the current query
    final asyncVideos = ref.watch(exerciseVideoProvider(_currentQuery));

    final barTheme = Theme.of(context).extension<BarChartTheme>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness & Tutorials')),
      body: Column(
        children: [
          // -- search bar --
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
                    color: barTheme.gridColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withValues(alpha: 0.2),
                        offset: Offset(0, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for exercises',
                      hintStyle: barTheme.labelStyle.copyWith(),
                      prefixIcon: Icon(Icons.search, color: barTheme.barColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: barTheme.barColor,
                        ),
                        onPressed: _performSearch,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // -- video list --
          Expanded(
            child: asyncVideos.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return Center(
                    child: Text(
                      'Search to find videos',
                      style: barTheme.labelStyle.copyWith(),
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
                    return _buildVideoCard(video, barTheme);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('No Such Video Exists.')),
            ),
          ),
        ],
      ),
    );
  }

  //helper function to build the video card
  Widget _buildVideoCard(FitnessVideo video, BarChartTheme barTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: barTheme.gridColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.2),
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
                      color: barTheme.gridColor,
                      child: Icon(Icons.broken_image, color: barTheme.barColor),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: barTheme.barColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    video.channelName,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: barTheme.barColor),
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
