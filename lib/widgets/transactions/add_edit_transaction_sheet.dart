import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transaction_item.dart';
import 'package:expense_tracker/models/category_item.dart';
import 'package:expense_tracker/theme/app_colors.dart';
import 'package:expense_tracker/utils/date_helpers.dart';

class AddEditTransactionSheet extends StatefulWidget {
  final List<CategoryItem> categories;
  final String currencySymbol;
  final TransactionItem? existingTransaction;
  final TransactionType initialType;
  final ValueChanged<TransactionItem> onSave;

  const AddEditTransactionSheet({
    super.key,
    required this.categories,
    required this.currencySymbol,
    this.existingTransaction,
    this.initialType = TransactionType.expense,
    required this.onSave,
  });

  @override
  State<AddEditTransactionSheet> createState() => _AddEditTransactionSheetState();
}

class _AddEditTransactionSheetState extends State<AddEditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  late TransactionType _selectedType;
  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late PaymentMethod _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;

    _selectedType = existing?.type ?? widget.initialType;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _selectedDate = existing?.date ?? DateTime.now();
    _selectedPaymentMethod = existing?.paymentMethod ?? PaymentMethod.cash;

    // Find valid category
    final availableCategories = _getCategoriesForType(_selectedType);
    if (existing != null && availableCategories.any((c) => c.id == existing.categoryId)) {
      _selectedCategoryId = existing.categoryId;
    } else {
      _selectedCategoryId = availableCategories.isNotEmpty ? availableCategories.first.id : 'expense_other';
    }
  }

  List<CategoryItem> _getCategoriesForType(TransactionType type) {
    final catType = type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    return widget.categories.where((c) => c.type == catType).toList();
  }

  void _onTypeChanged(TransactionType newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      final available = _getCategoriesForType(newType);
      if (available.isNotEmpty) {
        _selectedCategoryId = available.first.id;
      } else {
        _selectedCategoryId = newType == TransactionType.income ? 'salary' : 'expense_other';
      }
    });
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive amount'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final transaction = TransactionItem(
      id: widget.existingTransaction?.id,
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onSave(transaction);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingTransaction != null;
    final availableCategories = _getCategoriesForType(_selectedType);
    final accentColor = _selectedType == TransactionType.income ? AppColors.income : AppColors.expense;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header & Type Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Transaction' : 'New Transaction',
                    style: const TextStyle(
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
              const SizedBox(height: 12),

              // Segmented Type Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: _selectedType == TransactionType.expense,
                        activeColor: AppColors.expense,
                        onTap: () => _onTypeChanged(TransactionType.expense),
                      ),
                    ),
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _selectedType == TransactionType.income,
                        activeColor: AppColors.income,
                        onTap: () => _onTypeChanged(TransactionType.income),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount Input Field (Hero sized)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.currencySymbol,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Transaction Title',
                  hintText: 'e.g. Grocery Shopping, Uber ride, Salary...',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector Section
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 84,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableCategories.length,
                  itemBuilder: (context, index) {
                    final category = availableCategories[index];
                    final isSelected = category.id == _selectedCategoryId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                      },
                      child: Container(
                        width: 72,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color.withValues(alpha: 0.15)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? category.color : theme.colorScheme.outline.withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              color: category.color,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date & Payment Method Row
              Row(
                children: [
                  // Date Picker Button
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Text(
                                    DateHelpers.formatRelative(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Payment Method Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PaymentMethod>(
                          value: _selectedPaymentMethod,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_rounded),
                          items: PaymentMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Method',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Text(
                                    method.displayName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPaymentMethod = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Input Field
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add description, reference ID, receipt details...',
                  prefixIcon: Icon(Icons.note_alt_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Add ${_selectedType == TransactionType.income ? "Income" : "Expense"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
