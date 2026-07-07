import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/food_entry.dart';
import '../../providers/food_entries_provider.dart';

class AddEditFoodScreen extends ConsumerStatefulWidget {
  const AddEditFoodScreen({super.key, this.entry});

  final FoodEntry? entry;

  bool get isEditing => entry != null;

  @override
  ConsumerState<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends ConsumerState<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late final TextEditingController _morningMeal;
  late final TextEditingController _morningPrice;
  late final TextEditingController _afternoonMeal;
  late final TextEditingController _afternoonPrice;
  late final TextEditingController _nightMeal;
  late final TextEditingController _nightPrice;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _date = e?.date ?? DateTime.now();
    _morningMeal = TextEditingController(text: e?.morningMeal ?? '');
    _morningPrice = TextEditingController(text: _priceText(e?.morningPrice));
    _afternoonMeal = TextEditingController(text: e?.afternoonMeal ?? '');
    _afternoonPrice = TextEditingController(
      text: _priceText(e?.afternoonPrice),
    );
    _nightMeal = TextEditingController(text: e?.nightMeal ?? '');
    _nightPrice = TextEditingController(text: _priceText(e?.nightPrice));
    _notes = TextEditingController(text: e?.notes ?? '');

    for (final c in [_morningPrice, _afternoonPrice, _nightPrice]) {
      c.addListener(() => setState(() {}));
    }
  }

  String _priceText(double? value) {
    if (value == null || value == 0) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _morningMeal.dispose();
    _morningPrice.dispose();
    _afternoonMeal.dispose();
    _afternoonPrice.dispose();
    _nightMeal.dispose();
    _nightPrice.dispose();
    _notes.dispose();
    super.dispose();
  }

  double _parsePrice(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  double get _total =>
      _parsePrice(_morningPrice) +
      _parsePrice(_afternoonPrice) +
      _parsePrice(_nightPrice);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(foodEntriesProvider.notifier);
    final entry = FoodEntry(
      id: widget.entry?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      date: _date,
      morningMeal: _morningMeal.text.trim(),
      morningPrice: _parsePrice(_morningPrice),
      afternoonMeal: _afternoonMeal.text.trim(),
      afternoonPrice: _parsePrice(_afternoonPrice),
      nightMeal: _nightMeal.text.trim(),
      nightPrice: _parsePrice(_nightPrice),
      notes: _notes.text.trim(),
    );

    if (widget.isEditing) {
      notifier.update(entry);
    } else {
      notifier.add(entry);
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(widget.isEditing ? 'Entry updated' : 'Entry saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Food Entry' : 'Add Food Entry'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Label('Date'),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.keyboard_arrow_down),
                  ),
                  child: Text(Formatters.shortDate(_date)),
                ),
              ),
              const SizedBox(height: 20),

              _MealField(
                label: 'Morning Meal',
                icon: Icons.wb_sunny,
                iconColor: AppColors.warning,
                controller: _morningMeal,
              ),
              _PriceField(
                label: 'Morning Price (₹)',
                controller: _morningPrice,
              ),

              _MealField(
                label: 'Afternoon Meal',
                icon: Icons.wb_sunny_outlined,
                iconColor: AppColors.warning,
                controller: _afternoonMeal,
              ),
              _PriceField(
                label: 'Afternoon Price (₹)',
                controller: _afternoonPrice,
              ),

              _MealField(
                label: 'Night Meal',
                icon: Icons.nightlight_round,
                iconColor: AppColors.primary,
                controller: _nightMeal,
              ),
              _PriceField(label: 'Night Price (₹)', controller: _nightPrice),

              // ---- Live total ----
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Price',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Formatters.rupees(_total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _Label('Notes (Optional)'),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(
                  hintText: 'Add a note',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: const Text('SAVE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _MealField extends StatelessWidget {
  const _MealField({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.controller,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Idli, Sambar',
            prefixIcon: Icon(icon, color: iconColor),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter the meal';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: const InputDecoration(
            hintText: '0',
            prefixIcon: Icon(Icons.currency_rupee),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Enter price';
            final parsed = double.tryParse(text);
            if (parsed == null || parsed < 0) return 'Invalid price';
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
