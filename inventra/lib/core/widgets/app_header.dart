import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String storeName;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const AppHeader({
    super.key,
    required this.storeName,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notificationCount > 0
                      ? AppTheme.warning.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      notificationCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_outlined,
                      color: notificationCount > 0
                          ? AppTheme.warning
                          : Colors.grey.shade600,
                      size: 22,
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppTheme.danger,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
