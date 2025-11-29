class FitnessVideo {
  final String title;
  final String channelName;
  final String thumbnail;
  final String videoUrl;
  final String? duration;
  final String? publishDate;

  FitnessVideo({
    required this.title,
    required this.channelName,
    required this.thumbnail,
    required this.videoUrl,
    this.duration,
    this.publishDate,
  });

  factory FitnessVideo.fromApi(dynamic apiData) {
    return FitnessVideo(
      title: apiData.title ?? 'Untitled',
      channelName: apiData.channelTitle ?? 'Unknown Channel',
      thumbnail: apiData.thumbnail?.high?.url ?? '',
      videoUrl: apiData.url ?? '',
      duration: apiData.duration,
      publishDate: apiData.publishedAt,
    );
  }
}
