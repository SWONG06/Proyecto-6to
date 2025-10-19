import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/finance_models.dart';
import '../utils/format.dart';
import '../services/gemini_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final void Function(FinanceTransaction) onSaved;

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
  TxType _type = TxType.expense;
  String? _snackBarMessage;

  static const String _geminiApiKey = 'AIzaSyARluSO62zzBG1MEfDgtPslY8zEohTfXfY';
  late final GeminiService _geminiService = GeminiService(_geminiApiKey);

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
  void initState() {
    super.initState();
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
        _dateCtrl.text = dateShort(res);
      });
    }
  }

  Future<void> _scanReceipt() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permiso requerido'),
            content: const Text(
              'El permiso de cámara es necesario para escanear recibos. '
              'Por favor, habilítalo en la configuración de la app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Abrir configuración'),
              ),
            ],
          ),
        );
      } else {
        setState(() => _snackBarMessage = 'Permiso de cámara denegado');
      }
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (!mounted || image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Analizando recibo...'),
          ],
        ),
      ),
    );

    try {
      final data = await _geminiService.analyzeReceipt(image);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (data != null) {
        setState(() {
          if (data['amount'] != null) {
            _amountCtrl.text = data['amount'].toString();
          }
          if (data['date'] != null && data['date'].isNotEmpty) {
            try {
              _selectedDate = DateTime.parse(data['date']);
              _dateCtrl.text = dateShort(_selectedDate!);
            } catch (_) {}
          }
          if (data['description'] != null && data['description'].isNotEmpty) {
            _descCtrl.text = data['description'];
          }
          if (data['category'] != null &&
              _categories.contains(data['category'])) {
            _selectedCategory = data['category'];
          }
          if (data['paymentMethod'] != null &&
              _paymentMethods.contains(data['paymentMethod'])) {
            _selectedMethod = data['paymentMethod'];
          }
          _snackBarMessage = 'Datos extraídos del recibo';
        });
      } else {
        setState(() => _snackBarMessage = 'No se pudieron extraer datos del recibo');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _snackBarMessage = 'Error: $e');
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tx = FinanceTransaction(
      title: _descCtrl.text.trim().split('\n').first,
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
      category: _selectedCategory ?? '',
      date: _selectedDate ?? DateTime.now(),
      paymentMethod: _selectedMethod ?? 'N/D',
      type: _type,
      description: _descCtrl.text.trim(),
    );
    widget.onSaved(tx);
    setState(() {
      _snackBarMessage = 'Transacción guardada';
      _type = TxType.expense;
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

    // Colores adaptativos
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppleIconButton(
              icon: Icons.camera_alt_rounded,
              onPressed: _scanReceipt,
              tooltip: 'Escanear Recibo',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Selector de tipo de transacción
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: SegmentedButton<TxType>(
                  segments: [
                    ButtonSegment(
                      value: TxType.expense,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text(
                        'Gasto',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _type == TxType.expense ? textColor : hintColor,
                        ),
                      ),
                    ),
                    ButtonSegment(
                      value: TxType.income,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(
                        'Ingreso',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _type == TxType.income ? textColor : hintColor,
                        ),
                      ),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
              ),
              const SizedBox(height: 24),

              // Monto
              _buildAppleTextField(
                controller: _amountCtrl,
                label: 'Monto',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixText: r'$ ',
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 16),

              // Categoría
              _buildAppleDropdown<String>(
                value: _selectedCategory,
                label: 'Categoría',
                items: _categories,
                onChanged: (val) => setState(() => _selectedCategory = val),
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Fecha
              _buildAppleDateField(
                controller: _dateCtrl,
                label: 'Fecha',
                onTap: _pickDate,
                textColor: textColor,
                labelColor: labelColor,
                validator: (_) => _selectedDate == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // Método de pago
              _buildAppleDropdown<String>(
                value: _selectedMethod,
                label: 'Método de pago',
                items: _paymentMethods,
                onChanged: (val) => setState(() => _selectedMethod = val),
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
              ),
              const SizedBox(height: 16),

              // Descripción
              _buildAppleTextField(
                controller: _descCtrl,
                label: 'Descripción',
                minLines: 2,
                maxLines: 4,
                textColor: textColor,
                labelColor: labelColor,
                hintColor: hintColor,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 28),

              // Botón guardar
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
        hintStyle: TextStyle(
          color: hintColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      validator: validator,
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        suffixIcon: IconButton(
          icon: Icon(
            Icons.calendar_today_rounded,
            size: 22,
            color: cs.primary,
          ),
          onPressed: onTap,
        ),
      ),
      validator: validator,
    );
  }
}

/// Botón de ícono estilo Apple con efecto de interacción mejorado
class AppleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const AppleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<AppleIconButton> createState() => _AppleIconButtonState();
}

class _AppleIconButtonState extends State<AppleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onPressed();
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surfaceContainerHighest,
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: widget.color ?? cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}