import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gainers/features/activity/data/models/fitness_video_model.dart';
import 'package:gainers/features/activity/providers/exercise_tutorial_provider.dart';
import 'package:gainers/core/widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //helper to perform search
  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _currentQuery = _searchController.text;
      });
    }
  }

  //helper to open video url in external application
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

  //helper to format string for publish date
  String _timeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      final DateTime date = DateTime.parse(dateString);
      final Duration diff = DateTime.now().difference(date);

      if (diff.inDays > 365) {
        return '${(diff.inDays / 365).floor()} years ago';
      } else if (diff.inDays > 30) {
        return '${(diff.inDays / 30).floor()} months ago';
      } else if (diff.inDays > 7) {
        return '${(diff.inDays / 7).floor()} weeks ago';
      } else if (diff.inDays > 0) {
        return '${(diff.inDays).floor()} days ago';
      } else if (diff.inHours > 0) {
        return '${(diff.inHours).floor()} hours ago';
      } else if (diff.inMinutes > 0) {
        return '${(diff.inMinutes).floor()} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Long time ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    //watch the provider with the current query
    final tutorialState = ref.watch(exerciseVideoProvider(_currentQuery));

    //themes
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // -- app bar --
          // -- app bar --
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset(
                'images/Logo-Gainers.svg',
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            centerTitle: false,
          ),

          // -- header --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Resources',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),

          // -- search bar --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: CustomTextField(
                controller: _searchController,
                label: 'Search for exercises',
                prefixIcon: Icons.search,
                onSubmitted: (_) => _performSearch(),
              ),
            ),
          ),

          // -- video list --
          tutorialState.when(
            data: (videos) {
              if (videos.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No videos yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final video = videos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: _buildVideoCard(video, theme),
                  );
                }, childCount: videos.length),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  //helper function to build the video card
  Widget _buildVideoCard(FitnessVideo video, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _launchVideo(video.videoUrl),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- thumbnail --
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      video.duration ?? '??:??',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // -- metadata --
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          video.channelName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _timeAgo(video.publishDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
