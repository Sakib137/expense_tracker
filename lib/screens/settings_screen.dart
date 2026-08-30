import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/state/app_state_provider.dart';
import 'package:expense_tracker/models/user_settings.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/widgets/categories/add_category_dialog.dart';
import 'package:expense_tracker/widgets/common/custom_card.dart';
import 'package:expense_tracker/widgets/common/section_header.dart';
import 'package:expense_tracker/widgets/common/user_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openAddCategoryDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        onSave: (cat) => appState.addCategory(cat),
      ),
    );
  }

  Future<void> _showProfileImageOptions(BuildContext context, AppState appState) async {
    final theme = Theme.of(context);
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Profile Photo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select a photo from your device'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 600,
                      maxHeight: 600,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      await appState.updateUserSettings(profileImagePath: image.path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final isChannelError = e.toString().contains('channel-error') ||
                          e.toString().contains('MissingPluginException');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isChannelError
                                ? 'Please restart (re-run) the Flutter app once to enable device photo picker.'
                                : 'Could not pick image: $e',
                          ),
                          backgroundColor: isChannelError ? AppColors.warning : null,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.income.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.income),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Capture with device camera'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 600,
                      maxHeight: 600,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      await appState.updateUserSettings(profileImagePath: image.path);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final isChannelError = e.toString().contains('channel-error') ||
                          e.toString().contains('MissingPluginException');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isChannelError
                                ? 'Please restart (re-run) the Flutter app once to enable camera access.'
                                : 'Could not open camera: $e',
                          ),
                          backgroundColor: isChannelError ? AppColors.warning : null,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
              ),
              if (appState.settings.profileImagePath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.expense)),
                  subtitle: const Text('Reset to default initial avatar'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await appState.updateUserSettings(clearProfileImage: true);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _editUserName(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.settings.userName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Your Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                appState.updateUserSettings(userName: text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmResetData(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will restore default seed categories, sample transactions, and budgets. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App data reset successfully')),
                );
              }
            },
            child: const Text('Reset Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final categories = appState.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Categories'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          // User Profile Card
          CustomCard(
            child: Row(
              children: [
                UserAvatar(
                  size: 58,
                  userName: appState.settings.userName,
                  imagePath: appState.settings.profileImagePath,
                  showEditBadge: true,
                  onTap: () => _showProfileImageOptions(context, appState),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.settings.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () => _showProfileImageOptions(context, appState),
                        borderRadius: BorderRadius.circular(4),
                        child: Text(
                          appState.settings.profileImagePath != null
                              ? 'Change Profile Photo'
                              : 'Tap avatar to add photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: () => _editUserName(context, appState),
                  tooltip: 'Edit Name',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // App Preferences Section
          const SectionHeader(title: 'Preferences'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Currency Selector
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.attach_money_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Currency Symbol', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: appState.currencySymbol,
                      items: UserSettings.supportedCurrencies.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          appState.updateUserSettings(currencySymbol: val);
                        }
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Theme Mode Selector
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.dark_mode_rounded, color: AppColors.info, size: 20),
                  ),
                  title: const Text('Appearance / Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<ThemeMode>(
                      value: appState.themeMode,
                      items: const [
                        DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                        DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                        DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          appState.updateUserSettings(themeMode: val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Categories Management Section
          SectionHeader(
            title: 'Manage Categories',
            actionText: '+ Add Category',
            onAction: () => _openAddCategoryDialog(context, appState),
          ),
          CustomCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cat = categories[index];

                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 18),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    cat.isCustom ? 'Custom category' : 'Default category',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  trailing: cat.isCustom
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 20),
                          onPressed: () => appState.deleteCategory(cat.id),
                          tooltip: 'Delete custom category',
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cat.type.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Danger Zone / Reset Section
          const SectionHeader(title: 'Data Management'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restore_rounded, color: AppColors.expense, size: 20),
              ),
              title: const Text(
                'Reset All Data',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.expense,
                ),
              ),
              subtitle: const Text(
                'Clear custom records & reset to seed data',
                style: TextStyle(fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _confirmResetData(context, appState),
            ),
          ),
        ],
      ),
    );
  }
}
