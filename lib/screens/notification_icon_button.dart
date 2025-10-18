import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  void markAsRead() => isRead = true;

  String getRelativeTime() {
    return timestamp;
  }
}

class NotificationIconButton extends StatefulWidget {
  final int notificationCount;
  final VoidCallback onPressed;
  final List<NotificationItem> notifications;
  final Function(NotificationItem)? onNotificationTapped;

  const NotificationIconButton({
    super.key,
    required this.notificationCount,
    required this.onPressed,
    required this.notifications,
    this.onNotificationTapped,
  });

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showPanel = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

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
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _createOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    // Calcular posición optimal (evitar que salga de pantalla)
    double rightPosition = screenSize.width - offset.dx - size.width;
    double topPosition = offset.dy + size.height + 8;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closePanel,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            right: rightPosition.clamp(8.0, screenSize.width - 348),
            top: topPosition,
            child: Material(
              color: Colors.transparent,
              child: NotificationPanel(
                notifications: widget.notifications,
                onClose: _closePanel,
                onNotificationTapped: (notification) {
                  notification.markAsRead();
                  widget.onNotificationTapped?.call(notification);
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _closePanel() {
    setState(() => _showPanel = false);
    _removeOverlay();
  }

  void _onPressed() {
    _controller.forward().then((_) => _controller.reverse());

    setState(() {
      _showPanel = !_showPanel;
      if (_showPanel) {
        _createOverlay();
      } else {
        _removeOverlay();
      }
    });

    widget.onPressed();
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                _onPressed();
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
                  Icons.notifications_outlined,
                  size: 20,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          if (widget.notificationCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red[600],
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.notificationCount > 99 ? '99+' : widget.notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // ignore: non_constant_identifier_names
  NotificationFullScreenPage({required List<NotificationItem> notifications, required Null Function(dynamic notification) onNotificationTapped}) {}
}

class NotificationPanel extends StatefulWidget {
  final List<NotificationItem> notifications;
  final VoidCallback onClose;
  final Function(NotificationItem)? onNotificationTapped;

  const NotificationPanel({
    super.key,
    required this.notifications,
    required this.onClose,
    this.onNotificationTapped,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  bool _isFullScreen = false;

  int get _unreadCount => widget.notifications.where((n) => !n.isRead).length;

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isFullScreen) {
      return _buildFullScreenView(context, cs);
    }

    return _buildPanelView(context, cs);
  }

  Widget _buildPanelView(BuildContext context, ColorScheme cs) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, cs, isFullScreen: false),
          if (widget.notifications.isEmpty)
            _buildEmptyState(context, cs)
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: widget.notifications.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color: cs.outlineVariant.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final notification = widget.notifications[index];
                  return NotificationItemWidget(
                    notification: notification,
                    onTap: () {
                      widget.onNotificationTapped?.call(notification);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullScreenView(BuildContext context, ColorScheme cs) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _buildHeader(context, cs, isFullScreen: true),
            if (widget.notifications.isEmpty)
              Expanded(child: _buildEmptyState(context, cs))
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.notifications.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: cs.outlineVariant.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final notification = widget.notifications[index];
                    return NotificationItemWidget(
                      notification: notification,
                      onTap: () {
                        widget.onNotificationTapped?.call(notification);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs, {required bool isFullScreen}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificaciones',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (_unreadCount > 0)
                Text(
                  '$_unreadCount sin leer',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (!isFullScreen)
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded, size: 20),
                  onPressed: _toggleFullScreen,
                  tooltip: 'Ver en pantalla completa',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              IconButton(
                icon: Icon(isFullScreen ? Icons.close_rounded : Icons.close_rounded, size: 20),
                onPressed: isFullScreen ? () {
                  _toggleFullScreen();
                } : widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(shape: const CircleBorder()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: cs.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí aparecerán tus actualizaciones',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.outline.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItemWidget extends StatefulWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUnread = !widget.notification.isRead;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: isUnread
            ? cs.primary.withOpacity(0.08)
            : (_isHovered ? cs.surfaceContainerHighest : Colors.transparent),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.notification.color.withOpacity(0.15),
                  ),
                  child: Icon(
                    widget.notification.icon,
                    color: widget.notification.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.notification.title,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.notification.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.notification.timestamp,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.outline.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}