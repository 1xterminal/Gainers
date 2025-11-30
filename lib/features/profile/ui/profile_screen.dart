import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/auth/providers/auth_provider.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gainers/core/services/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final profileAsync = ref.watch(getProfileProvider(user?.id ?? ''));
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Text(
                'Account',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Header
                profileAsync.when(
                  data: (profile) {
                    final name =
                        profile?.displayName ?? profile?.username ?? 'Gainer';
                    final email = user?.email ?? '';
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'G',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error loading profile'),
                ),
                const SizedBox(height: 40),

                // Settings List
                _buildSettingsTile(
                  context,
                  icon: Icons.grid_view,
                  title: 'Home Tiles',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_active,
                  title: 'Test Notification',
                  onTap: () async {
                    await NotificationService().showInstantNotification();
                  },
                ),
                const SizedBox(height: 24),
                _buildSettingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () {
                    ref.read(authNotifierProvider.notifier).logout();
                  },
                  isDestructive: true,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : theme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : theme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
