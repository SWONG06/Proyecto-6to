import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final void Function(Transaction) onSaved;

  const AddTransactionScreen({
    super.key,
    required this.onSaved,
    required ThemeMode themeMode,
    required ValueChanged<bool> onThemeChanged,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.expense;
  String? _snackBarMessage;

  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;
  String? _selectedMethod;

  final List<String> _categories = [
    'Transporte',
    'Alimentación',
    'Suministros',
    'Ventas',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Otros'
  ];

  final List<String> _paymentMethods = [
    'Tarjeta Visa',
    'Tarjeta MasterCard',
    'Transferencia',
    'Efectivo',
    'Cheque',
    'Otro'
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDate: _selectedDate ?? now,
      locale: const Locale('es'),
    );
    if (!mounted) return;
    if (res != null) {
      setState(() {
        _selectedDate = res;
        _dateCtrl.text = formatDate(res);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _descCtrl.text.trim().split('\n').first,
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
      category: _selectedCategory ?? '',
      date: _selectedDate ?? DateTime.now(),
      type: _type,
    );
    widget.onSaved(tx);
    setState(() {
      _snackBarMessage = 'Transacción guardada';
      _type = TransactionType.expense;
      _selectedDate = null;
      _selectedCategory = null;
      _selectedMethod = null;
      _dateCtrl.clear();
    });
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.black54;

    if (_snackBarMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_snackBarMessage!)));
        setState(() => _snackBarMessage = null);
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Nueva Transacción',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Tipo de transacción
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<TransactionType>(
                  segments: [
                    ButtonSegment(
                      value: TransactionType.expense,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text(
                        'Gasto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _type == TransactionType.expense
                              ? textColor
                              : hintColor,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(
                        'Ingreso',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _type == TransactionType.income
                              ? textColor
                              : hintColor,
                        ),
                      ),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
              ),
              const SizedBox(height: 24),

              // 🔹 Monto
              _buildAppleTextField(
                controller: _amountCtrl,
                label: 'Monto',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixText: r'S/ ',
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 16),

              // 🔹 Categoría
              _buildAppleDropdown<String>(
                value: _selectedCategory,
                label: 'Categoría',
                items: _categories,
                onChanged: (val) => setState(() => _selectedCategory = val),
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Fecha
              _buildAppleDateField(
                controller: _dateCtrl,
                label: 'Fecha',
                onTap: _pickDate,
                textColor: textColor,
                labelColor: labelColor,
                validator: (_) =>
                    _selectedDate == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Descripción
              _buildAppleTextField(
                controller: _descCtrl,
                label: 'Descripción',
                minLines: 2,
                maxLines: 4,
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 28),

              // 🔹 Botón Guardar
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded, size: 22),
                  label: const Text(
                    'Guardar Transacción',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 TextField estilo Apple
  Widget _buildAppleTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    int? minLines,
    int? maxLines,
    String? Function(String?)? validator,
    double fontSize = 17,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines ?? 1,
      maxLines: maxLines ?? 1,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
        hintStyle: TextStyle(color: hintColor),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      validator: validator,
    );
  }

  // 🔸 Dropdown estilo Apple
  Widget _buildAppleDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required Function(T?) onChanged,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
    String? Function(T?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<T>(
      value: value,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // 🔸 Campo de fecha estilo Apple
  Widget _buildAppleDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color labelColor,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today_rounded, size: 22, color: cs.primary),
          onPressed: onTap,
        ),
      ),
      validator: validator,
    );
  }
}
