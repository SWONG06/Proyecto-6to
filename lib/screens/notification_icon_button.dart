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

  void _onPressed() {
    _controller.forward().then((_) => _controller.reverse());

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return NotificationFullScreenDialog(
          notifications: widget.notifications,
          onNotificationTapped: (notification) {
            notification.markAsRead();
            widget.onNotificationTapped?.call(notification);
          },
        );
      },
    );

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
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
                  widget.notificationCount > 99
                      ? '99+'
                      : widget.notificationCount.toString(),
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
    );
  }
}

class NotificationFullScreenDialog extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(NotificationItem)? onNotificationTapped;

  const NotificationFullScreenDialog({
    super.key,
    required this.notifications,
    this.onNotificationTapped,
  });

  @override
  State<NotificationFullScreenDialog> createState() =>
      _NotificationFullScreenDialogState();
}

class _NotificationFullScreenDialogState
    extends State<NotificationFullScreenDialog> {
  late List<NotificationItem> _notifications;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _notifications.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        for (var notif in _notifications) {
          _selectedIds.add(notif.id);
        }
      }
    });
  }

  void _deleteSelected() {
    final count = _selectedIds.length;
    setState(() {
      _notifications.removeWhere((n) => _selectedIds.contains(n.id));
      _selectedIds.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 1
              ? 'Notificación eliminada'
              : '$count notificaciones eliminadas',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildHeader(context, cs),
            if (_notifications.isEmpty)
              Expanded(child: _buildEmptyState(context, cs))
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: cs.outlineVariant.withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isSelected = _selectedIds.contains(notification.id);

                    return NotificationItemWidget(
                      notification: notification,
                      isSelected: isSelected,
                      isSelectionMode: _isSelectionMode,
                      onTap: _isSelectionMode
                          ? () => _toggleSelection(notification.id)
                          : () {
                              widget.onNotificationTapped?.call(notification);
                              setState(() {});
                            },
                      onLongPress: () {
                        setState(() {
                          _isSelectionMode = true;
                          _toggleSelection(notification.id);
                        });
                      },
                    );
                  },
                ),
              ),
            if (_isSelectionMode && _selectedIds.isNotEmpty)
              _buildSelectionBar(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          if (_isSelectionMode)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedIds.length} seleccionada${_selectedIds.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificaciones',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount sin leer',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          Row(
            children: [
              if (_isSelectionMode)
                IconButton(
                  icon: Icon(
                    _selectedIds.length == _notifications.length
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 28,
                    color: _selectedIds.length == _notifications.length
                        ? cs.primary
                        : cs.outline,
                  ),
                  onPressed: _selectAll,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: _isSelectionMode
                    ? _cancelSelection
                    : () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                style: IconButton.styleFrom(shape: const CircleBorder()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context, ColorScheme cs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: cs.primary.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _cancelSelection,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _deleteSelected,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.black87 : Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
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
            size: 80,
            color: cs.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay notificaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: cs.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí aparecerán tus actualizaciones',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.outline.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItemWidget extends StatefulWidget {
  final NotificationItem notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<NotificationItemWidget> createState() =>
      _NotificationItemWidgetState();
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
        color: widget.isSelected
            ? cs.primary.withOpacity(0.15)
            : isUnread
                ? cs.primary.withOpacity(0.08)
                : (_isHovered
                    ? cs.surfaceContainerHighest
                    : Colors.transparent),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 5),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isSelected ? cs.primary : cs.outline,
                          width: 2,
                        ),
                        color: widget.isSelected
                            ? cs.primary.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: widget.isSelected
                          ? Icon(
                              Icons.check,
                              color: cs.primary,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.notification.color.withOpacity(0.15),
                  ),
                  child: Icon(
                    widget.notification.icon,
                    color: widget.notification.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread && !widget.isSelectionMode)
                            Container(
                              margin: const EdgeInsets.only(left: 12),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cs.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.notification.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.notification.timestamp,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.outline.withOpacity(0.7),
                          fontSize: 12,
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