import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final void Function(FinanceTransaction) onSaved;
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;

  const AddTransactionScreen({
    super.key,
    required this.onSaved,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TxType _type;
  String? _snackBarMessage;

  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

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

  @override
  void initState() {
    super.initState();
    _type = TxType.expense;
  }

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
        _dateCtrl.text = _formatDate(res);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tx = FinanceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _descCtrl.text.trim().split('\n').first,
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
      category: _selectedCategory ?? '',
      date: _selectedDate ?? DateTime.now(),
      type: _type, paymentMethod: '',
    );
    widget.onSaved(tx);
    setState(() {
      _snackBarMessage = 'Transacción guardada';
      _type = TxType.expense;
      _selectedDate = null;
      _selectedCategory = null;
      _dateCtrl.clear();
      _amountCtrl.clear();
      _descCtrl.clear();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_snackBarMessage!),
            backgroundColor: cs.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
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
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: cs.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Tipo de transacción Premium
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: SegmentedButton<TxType>(
                  segments: [
                    ButtonSegment(
                      value: TxType.expense,
                      icon: const Icon(Icons.arrow_downward_rounded, size: 20),
                      label: Text(
                        'Gasto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: TxType.income,
                      icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                      label: Text(
                        'Ingreso',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 🔹 Monto con estilo premium
              _buildModernTextField(
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
                fontSize: 24,
                fontWeight: FontWeight.w800,
                icon: Icons.local_activity_rounded,
              ),
              const SizedBox(height: 18),

              // 🔹 Categoría moderna
              _buildModernDropdown<String>(
                value: _selectedCategory,
                label: 'Categoría',
                items: _categories,
                onChanged: (val) => setState(() => _selectedCategory = val),
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
                icon: Icons.category_rounded,
              ),
              const SizedBox(height: 18),

              // 🔹 Fecha moderna
              _buildModernDateField(
                controller: _dateCtrl,
                label: 'Fecha',
                onTap: _pickDate,
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (_) =>
                    _selectedDate == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 18),

              // 🔹 Descripción moderna
              _buildModernTextField(
                controller: _descCtrl,
                label: 'Descripción',
                minLines: 3,
                maxLines: 5,
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                icon: Icons.description_rounded,
              ),
              const SizedBox(height: 32),

              // 🔹 Botón Guardar Premium
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withBlue(220)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Guardar Transacción',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
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

  // 🔸 TextField moderno
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
    IconData? icon,
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
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, color: cs.primary, size: 22),
              )
            : null,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: labelColor,
          letterSpacing: 0.2,
        ),
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w500),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2.5),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      validator: validator,
    );
  }

  // 🔸 Dropdown moderno
  Widget _buildModernDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required Function(T?) onChanged,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
    IconData? icon,
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
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, color: cs.primary, size: 22),
              )
            : null,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: labelColor,
          letterSpacing: 0.2,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2.5),
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
                  fontWeight: FontWeight.w600,
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

  // 🔸 Campo de fecha moderno
  Widget _buildModernDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color labelColor,
    required Color hintColor,
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
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(Icons.calendar_today_rounded, color: cs.primary, size: 22),
        ),
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: labelColor,
          letterSpacing: 0.2,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2.5),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      validator: validator,
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}