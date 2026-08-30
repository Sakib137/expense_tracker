import 'package:flutter/material.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/icon_helper.dart';
import 'package:uuid/uuid.dart';

class AddCategoryDialog extends StatefulWidget {
  final ValueChanged<CategoryItem> onSave;

  const AddCategoryDialog({super.key, required this.onSave});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  CategoryType _selectedType = CategoryType.expense;
  String _selectedIconKey = 'shopping_bag';
  int _selectedColorValue = AppColors.categoryPalette.first.toARGB32();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final newCategory = CategoryItem(
      id: 'custom_${const Uuid().v4().substring(0, 8)}',
      name: name,
      iconKey: _selectedIconKey,
      colorValue: _selectedColorValue,
      type: _selectedType,
      isCustom: true,
    );

    widget.onSave(newCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = Color(_selectedColorValue);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icon Preview Circle
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selectedColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: selectedColor, width: 2),
                ),
                child: Icon(
                  IconHelper.getIcon(_selectedIconKey),
                  color: selectedColor,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name Input
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Subscriptions, Pet Care...',
              ),
            ),
            const SizedBox(height: 16),

            // Type Selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Expense')),
                    selected: _selectedType == CategoryType.expense,
                    selectedColor: AppColors.expense.withValues(alpha: 0.2),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = CategoryType.expense);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Income')),
                    selected: _selectedType == CategoryType.income,
                    selectedColor: AppColors.income.withValues(alpha: 0.2),
                    onSelected: (val) {
                      if (val) setState(() => _selectedType = CategoryType.income);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color Palette Selector
            Text(
              'Select Color',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.categoryPalette.map((color) {
                final isSelected = color.toARGB32() == _selectedColorValue;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = color.toARGB32()),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Icon Selector Grid
            Text(
              'Select Icon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: IconHelper.availableIcons.length,
                itemBuilder: (context, index) {
                  final key = IconHelper.availableIcons.keys.elementAt(index);
                  final icon = IconHelper.availableIcons[key]!;
                  final isSelected = key == _selectedIconKey;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconKey = key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? selectedColor : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Create Category'),
            ),
          ],
        ),
      ),
    );
  }
}
