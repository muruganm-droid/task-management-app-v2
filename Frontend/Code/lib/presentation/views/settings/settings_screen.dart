import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../providers.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../theme.dart';
import '../animations/animated_list_item.dart';
import '../../../core/utils/haptic_helper.dart';
import 'ai_chat_screen.dart';
import 'shooter_game_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initControllers(AuthState authState) {
    if (_initialized) return;
    final user = authState.user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    _initControllers(authState);

    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    final isDark = context.isDark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  children: [
                    _buildProfileHeader(user, isDark),
                    const SizedBox(height: 28),
                    _buildThemeSection(themeMode, isDark),
                    const SizedBox(height: 28),
                    _buildProfileSection(authState, isDark),
                    const SizedBox(height: 28),
                    _buildPasswordSection(authState, isDark),
                    const SizedBox(height: 28),
                    _buildFunZoneSection(isDark),
                    const SizedBox(height: 28),
                    _buildLogoutButton(isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return FadeInWidget(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.textPrimaryColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isDark) {
    return AnimatedListItem(
      index: 0,
      child: Center(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(ThemeMode themeMode, bool isDark) {
    return AnimatedListItem(
      index: 1,
      child: _buildSectionCard(
        isDark: isDark,
        title: 'Appearance',
        icon: Icons.palette_outlined,
        iconColor: AppTheme.secondaryColor,
        child: Column(
          children: [
            _buildThemeOption(
              'System',
              'Follow device theme',
              Icons.phone_android_rounded,
              themeMode == ThemeMode.system,
              isDark,
              () => _setThemeMode(ThemeMode.system),
            ),
            Divider(
              height: 1,
              indent: 46,
              color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
            ),
            _buildThemeOption(
              'Light',
              'Always use light theme',
              Icons.light_mode_rounded,
              themeMode == ThemeMode.light,
              isDark,
              () => _setThemeMode(ThemeMode.light),
            ),
            Divider(
              height: 1,
              indent: 46,
              color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
            ),
            _buildThemeOption(
              'Dark',
              'Always use dark theme',
              Icons.dark_mode_rounded,
              themeMode == ThemeMode.dark,
              isDark,
              () => _setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppTheme.primaryColor
                    : context.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient:
                    isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : isDark
                        ? AppTheme.darkBorder
                        : AppTheme.borderColor,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.borderColor,
                        width: 2,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _setThemeMode(ThemeMode mode) {
    ref.read(themeModeProvider.notifier).state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    prefs.setString('theme_mode', value);
  }

  Widget _buildProfileSection(AuthState authState, bool isDark) {
    return AnimatedListItem(
      index: 2,
      child: _buildSectionCard(
        isDark: isDark,
        title: 'Profile',
        icon: Icons.person_outline_rounded,
        iconColor: AppTheme.primaryColor,
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bioController,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                prefixIcon: Icon(Icons.info_outlined),
              ),
              maxLength: 300,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ScaleOnTap(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(authViewModelProvider.notifier)
                            .updateProfile(
                              name: _nameController.text.trim(),
                              bio: _bioController.text.trim(),
                            );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor
                            .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection(AuthState authState, bool isDark) {
    return AnimatedListItem(
      index: 3,
      child: _buildSectionCard(
        isDark: isDark,
        title: 'Change Password',
        icon: Icons.lock_outline_rounded,
        iconColor: AppTheme.warningColor,
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: context.textPrimaryColor),
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ScaleOnTap(
                onTap: authState.isLoading
                    ? null
                    : () async {
                        final newPassword = _newPasswordController.text;
                        if (_currentPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Current password is required'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        if (newPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('New password is required'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        if (newPassword.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password must be at least 8 characters'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        if (!newPassword.contains(RegExp(r'[A-Z]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password must contain an uppercase letter'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        if (!newPassword.contains(RegExp(r'[0-9]'))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password must contain a number'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        if (newPassword !=
                            _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Passwords do not match'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        final success = await ref
                            .read(authViewModelProvider.notifier)
                            .changePassword(
                              _currentPasswordController.text,
                              _newPasswordController.text,
                            );
                        if (success && mounted) {
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password changed successfully'),
                              backgroundColor:
                                  AppTheme.successColor,
                            ),
                          );
                        }
                      },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkBorder
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunZoneSection(bool isDark) {
    return AnimatedListItem(
      index: 4,
      child: _buildSectionCard(
        isDark: isDark,
        title: 'Fun Zone',
        icon: Icons.gamepad_rounded,
        iconColor: AppTheme.accentColor,
        child: Column(
          children: [
            _buildFunZoneTile(
              icon: Icons.smart_toy_rounded,
              iconColor: AppTheme.primaryColor,
              title: 'Chat with AI',
              subtitle: 'Talk about anything in any language',
              isDark: isDark,
              onTap: () {
                Haptic.light();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                );
              },
            ),
            Divider(
              height: 1,
              indent: 46,
              color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
            ),
            _buildFunZoneTile(
              icon: Icons.rocket_launch_rounded,
              iconColor: AppTheme.secondaryColor,
              title: 'Space Shooter',
              subtitle: 'Quick break? Destroy some aliens!',
              isDark: isDark,
              onTap: () {
                Haptic.light();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShooterGameScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunZoneTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: context.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return AnimatedListItem(
      index: 5,
      child: ScaleOnTap(
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor:
                  isDark ? AppTheme.darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  color: context.textSecondaryColor,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
                ScaleOnTap(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.errorGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(authViewModelProvider.notifier).logout();
          }
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.errorColor.withValues(alpha: 0.08)
                : AppTheme.errorColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
        ),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
