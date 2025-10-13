import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/finance_models.dart';
import '../utils/format.dart';
import '../services/gemini_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final void Function(FinanceTransaction) onSaved;
  final ThemeMode themeMode;
  final void Function(bool isDark) onThemeChanged;

  const AddTransactionScreen({
    super.key,
    required this.onSaved,
    this.themeMode = ThemeMode.system,
    required this.onThemeChanged,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TxType _type = TxType.expense;
  late AnimationController _themeAnimationController;
  String? _snackBarMessage;

  // Clave de API (usa una variable segura en producción)
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
    _themeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.themeMode == ThemeMode.dark) {
      _themeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _descCtrl.dispose();
    _themeAnimationController.dispose();
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
    if (!mounted) return; // ✅ Verifica antes de usar context
    if (res != null) {
      setState(() {
        _selectedDate = res;
        _dateCtrl.text = dateShort(res);
      });
    }
  }

  Future<void> _scanReceipt() async {
    final status = await Permission.camera.request();
    if (!mounted) return; // ✅ Seguridad ante desmontaje

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

    // Mostrar diálogo de carga
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
      Navigator.of(context).pop(); // Cierra el diálogo

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
        });
        _snackBarMessage = 'Datos extraídos del recibo';
      } else {
        _snackBarMessage = 'No se pudieron extraer datos del recibo';
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

    if (_snackBarMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_snackBarMessage!)));
        _snackBarMessage = null;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Transacción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Escanear Recibo',
            onPressed: _scanReceipt,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _ModernThemeToggle(
              isDark: widget.themeMode == ThemeMode.dark,
              onToggle: (isDark) {
                widget.onThemeChanged(isDark);
                if (isDark) {
                  _themeAnimationController.forward();
                } else {
                  _themeAnimationController.reverse();
                }
              },
              animationController: _themeAnimationController,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Form(
          key: _formKey,
          child: Column(children: [
            SegmentedButton<TxType>(
              segments: const [
                ButtonSegment(
                    value: TxType.expense,
                    icon: Icon(Icons.south_west),
                    label: Text('Gasto')),
                ButtonSegment(
                    value: TxType.income,
                    icon: Icon(Icons.north_east),
                    label: Text('Ingreso')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Monto*', prefixText: r'$ '),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Categoría*'),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _dateCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha*',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate),
              ),
              validator: (_) => _selectedDate == null ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(labelText: 'Método de pago'),
              items: _paymentMethods
                  .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMethod = val),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Descripción*'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar Gasto'),
                style: FilledButton.styleFrom(backgroundColor: cs.primary),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ------------------ WIDGET TOGGLE ------------------

class _ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const _ModernThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onToggle(!isDark),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final progress = animationController.value;

          return Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Color.lerp(const Color(0xFFFFB347),
                      const Color(0xFF1A1A2E), progress)!,
                  Color.lerp(const Color(0xFFFFD700),
                      const Color(0xFF16213E), progress)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (progress > 0.5)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StarsPainter(opacity: (progress - 0.5) * 2),
                    ),
                  ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment:
                      isDark ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: isDark
                          ? const Icon(Icons.nightlight_round,
                              key: ValueKey('dark'),
                              color: Color(0xFF1A1A2E),
                              size: 16)
                          : const Icon(Icons.wb_sunny_rounded,
                              key: ValueKey('light'),
                              color: Color(0xFFFFB347),
                              size: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double opacity;
  const _StarsPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    final stars = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
