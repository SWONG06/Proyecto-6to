import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<bool> onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _showLogo = true;
  late AnimationController _themeAnimationController;

  File? _profileImage;

  // Datos editables
  String _name = "Ana Garcia";
  String _email = "ana.garcia@teca-sl.com";
  String _phone = "+34 600 000 000";
  String _company = "Tecnologia Avanzada S.L.";
  String _position = "Gerente Financiero";

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

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showLogo = false);
    });
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    super.dispose();
  }

  // Elegir imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Modal para editar perfil
  void _editProfile() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final companyController = TextEditingController(text: _company);
    final positionController = TextEditingController(text: _position);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              "Editar perfil",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Teléfono"),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Empresa"),
            ),
            TextField(
              controller: positionController,
              decoration: const InputDecoration(labelText: "Cargo"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _email = emailController.text;
                  _phone = phoneController.text;
                  _company = companyController.text;
                  _position = positionController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar cambios"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          // Interruptor de tema
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ModernThemeToggle(
              isDark: isDark,
              onToggle: (isDarkMode) {
                widget.onThemeChanged(isDarkMode);
                if (isDarkMode) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editProfile,
        icon: const Icon(Icons.edit),
        label: const Text("Editar perfil"),
      ),
      body: _showLogo
          ? const Center(
              child: CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.12),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(
                                    Icons.camera_alt,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$_position\n$_company",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const _SectionTitle('Información personal'),
                Card(
                  child: Column(
                    children: [
                      _InfoTile(label: 'Nombre completo', value: _name),
                      const Divider(height: 1),
                      _InfoTile(label: 'Correo electrónico', value: _email),
                      const Divider(height: 1),
                      _InfoTile(label: 'Teléfono', value: _phone),
                    ],
                  ),
                ),
                const _SectionTitle('Información empresarial'),
                Card(
                  child: Column(
                    children: [
                      _InfoTile(label: 'Empresa', value: _company),
                      const Divider(height: 1),
                      _InfoTile(label: 'Cargo', value: _position),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------
// Widgets auxiliares
// ---------------------

class ModernThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;
  final AnimationController animationController;

  const ModernThemeToggle({
    required this.isDark,
    required this.onToggle,
    required this.animationController,
    super.key,
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
                  Color.lerp(
                        const Color(0xFFFFB347),
                        const Color(0xFF1A1A2E),
                        progress,
                      ) ??
                      Colors.orange,
                  Color.lerp(
                        const Color(0xFFFFD700),
                        const Color(0xFF16213E),
                        progress,
                      ) ??
                      Colors.amber,
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
                      painter: _StarsPainter(
                          opacity: (progress - 0.5) * 2),
                    ),
                  ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: isDark
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                            scale: animation, child: child);
                      },
                      child: isDark
                          ? Icon(
                              Icons.nightlight_round,
                              key: const ValueKey('dark'),
                              color: const Color(0xFF1A1A2E),
                              size: 16,
                            )
                          : Icon(
                              Icons.wb_sunny_rounded,
                              key: const ValueKey('light'),
                              color: const Color(0xFFFFB347),
                              size: 16,
                            ),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child:
          Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
      ),
    );
  }
}