import 'package:flutter/material.dart';
import 'package:open_tv/refresh_service.dart';

const _bottomNavHeight = 80.0;

class RefreshBanner extends StatelessWidget {
  final bool hasBottomNav;
  const RefreshBanner({super.key, this.hasBottomNav = false});

  @override
  Widget build(BuildContext context) {
    final service = RefreshService.instance;
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                service.isRefreshing,
                service.playerVisible,
              ]),
              builder: (context, _) =>
                  service.isRefreshing.value && !service.playerVisible.value
                  ? _Banner(hasBottomNav: hasBottomNav)
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final bool hasBottomNav;
  const _Banner({required this.hasBottomNav});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        bottom: hasBottomNav ? _bottomNavHeight + 12 : 12,
      ),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                "Refresh in progress",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
