import 'package:flutter/material.dart';
import 'package:open_tv/error.dart';
import 'package:open_tv/task_service.dart';

const _bottomNavHeight = 80.0;
const _snackBarClearance = 50.0;
const _edgeMargin = 12.0;

class TaskBanner extends StatelessWidget {
  final bool hasBottomNav;
  const TaskBanner({super.key, this.hasBottomNav = false});

  @override
  Widget build(BuildContext context) {
    final service = TaskService.instance;
    return Positioned.fill(
      child: IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                service.runningTask,
                service.playerVisible,
                Error.visibleSnackBars,
              ]),
              builder: (context, _) =>
                  service.busy && !service.playerVisible.value
                  ? _Banner(
                      label: service.runningTask.value!,
                      hasBottomNav: hasBottomNav,
                      hasSnackBar: Error.visibleSnackBars.value > 0,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String label;
  final bool hasBottomNav;
  final bool hasSnackBar;
  const _Banner({
    required this.label,
    required this.hasBottomNav,
    required this.hasSnackBar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: _edgeMargin,
        bottom:
            (hasBottomNav ? _bottomNavHeight : 0) +
            (hasSnackBar ? _snackBarClearance : _edgeMargin),
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
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
