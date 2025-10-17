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
  late AnimationController _profileLoadController;

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

    _profileLoadController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.themeMode == ThemeMode.dark) {
      _themeAnimationController.value = 1.0;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _showLogo = false);
        _profileLoadController.forward();
      }
    });
  }

  @override
  void dispose() {
    _themeAnimationController.dispose();
    _profileLoadController.dispose();
    super.dispose();
  }

  // Elegir imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Modal para editar perfil estilo Apple
  void _editProfile() {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final companyController = TextEditingController(text: _company);
    final positionController = TextEditingController(text: _position);

    final isDark = widget.themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              "Editar perfil",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            
            _AppleTextField(
              controller: nameController,
              label: "Nombre",
              icon: Icons.person_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            
            _AppleTextField(
              controller: emailController,
              label: "Correo",
              icon: Icons.email_rounded,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            _AppleTextField(
              controller: phoneController,
              label: "Teléfono",
              icon: Icons.phone_rounded,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            _AppleTextField(
              controller: companyController,
              label: "Empresa",
              icon: Icons.business_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            
            _AppleTextField(
              controller: positionController,
              label: "Cargo",
              icon: Icons.work_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            
            // Botón estilo Apple
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _name = nameController.text;
                      _email = emailController.text;
                      _phone = phoneController.text;
                      _company = companyController.text;
                      _position = positionController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Text(
                      "Guardar cambios",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Perfil",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
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
        elevation: 4,
        backgroundColor: cs.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          "Editar perfil",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _showLogo
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withOpacity(0.2),
                      cs.primary.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(Icons.person_rounded, size: 60, color: cs.primary),
              ),
            )
          : FadeTransition(
              opacity: _profileLoadController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _profileLoadController,
                  curve: Curves.easeOut,
                )),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    // Card de perfil principal
                    _AppleCard(
                      isDark: isDark,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _profileImage == null
                                          ? LinearGradient(
                                              colors: [
                                                cs.primary.withOpacity(0.2),
                                                cs.primary.withOpacity(0.1),
                                              ],
                                            )
                                          : null,
                                      image: _profileImage != null
                                          ? DecorationImage(
                                              image: FileImage(_profileImage!),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: cs.primary.withOpacity(0.3),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: _profileImage == null
                                        ? Icon(
                                            Icons.camera_alt_rounded,
                                            color: cs.primary,
                                            size: 32,
                                          )
                                        : null,
                                  ),
                                  if (_profileImage == null)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: cs.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF1C1C1E)
                                                : Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      letterSpacing: -0.5,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _position,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: cs.primary,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _company,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.5),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _AppleSectionTitle('Información personal', isDark: isDark),
                    const SizedBox(height: 8),
                    
                    _AppleCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          _AppleInfoTile(
                            icon: Icons.person_rounded,
                            label: 'Nombre completo',
                            value: _name,
                            isDark: isDark,
                            cs: cs,
                          ),
                          _Divider(isDark: isDark),
                          _AppleInfoTile(
                            icon: Icons.email_rounded,
                            label: 'Correo electrónico',
                            value: _email,
                            isDark: isDark,
                            cs: cs,
                          ),
                          _Divider(isDark: isDark),
                          _AppleInfoTile(
                            icon: Icons.phone_rounded,
                            label: 'Teléfono',
                            value: _phone,
                            isDark: isDark,
                            cs: cs,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _AppleSectionTitle('Información empresarial', isDark: isDark),
                    const SizedBox(height: 8),
                    
                    _AppleCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          _AppleInfoTile(
                            icon: Icons.business_rounded,
                            label: 'Empresa',
                            value: _company,
                            isDark: isDark,
                            cs: cs,
                          ),
                          _Divider(isDark: isDark),
                          _AppleInfoTile(
                            icon: Icons.work_rounded,
                            label: 'Cargo',
                            value: _position,
                            isDark: isDark,
                            cs: cs,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ---------------------
// Widgets auxiliares
// ---------------------

class _AppleCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _AppleCard({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1C1C1E),
                  const Color(0xFF2C2C2E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF5F5F7),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AppleSectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;

  const _AppleSectionTitle(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AppleInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final ColorScheme cs;
  final bool isLast;

  const _AppleInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.cs,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;

  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
      ),
    );
  }
}

class _AppleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;

  const _AppleTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
          letterSpacing: -0.3,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.5),
            letterSpacing: -0.2,
          ),
          prefixIcon: Icon(
            icon,
            color: cs.primary,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

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
                  color: (isDark ? Colors.blue : Colors.orange)
                      .withOpacity(0.3),
                  blurRadius: 12,
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
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: isDark
                          ? const Icon(
                              Icons.nightlight_round,
                              key: ValueKey('dark'),
                              color: Color(0xFF1A1A2E),
                              size: 16,
                            )
                          : const Icon(
                              Icons.wb_sunny_rounded,
                              key: ValueKey('light'),
                              color: Color(0xFFFFB347),
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