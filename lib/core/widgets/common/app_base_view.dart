import 'package:flutter/material.dart';
import 'package:nexlinks/core/widgets/common/slide_animation.dart';
import 'package:nexlinks/core/widgets/common/app_status_wrapper.dart';
import 'package:nexlinks/core/services/connectivity_service.dart';
import 'package:nexlinks/core/widgets/common/no_internet_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBaseView extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final dynamic error;
  final bool isEmpty;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final bool showGlows;
  final Color? backgroundColor;

  const AppBaseView({
    super.key,
    required this.child,
    this.isLoading = false,
    this.error,
    this.isEmpty = false,
    this.onRetry,
    this.emptyMessage = "No results",
    this.showGlows = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    return Material(
      color: Colors.transparent,
      child: SlideAnimation(
        child: Container(
          color: bgColor,
          child: Stack(
            children: [
              AppStatusWrapper(
                isLoading: isLoading,
                error: error,
                isEmpty: isEmpty,
                onRetry: onRetry,
                emptyMessage: emptyMessage,
                child: child,
              ),
              StreamBuilder<ConnectivityStatus>(
                stream: context.read<ConnectivityService>().statusStream,
                builder: (context, snapshot) {
                  if (snapshot.data == ConnectivityStatus.offline) {
                    return const NoInternetBanner();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
