// business-app/eucalypsInsight/eucalysp_insight_app/lib/app/core/widgets/business_data_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';

class BusinessDataView<T> extends StatelessWidget {
  final Widget Function(T data) successBuilder;
  final Widget Function(String)? errorBuilder;
  final Widget? loadingBuilder;
  final Widget? initialBuilder;
  final VoidCallback?
  onRefresh; // Callback for pull-to-refresh and default error retry

  const BusinessDataView({
    required this.successBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.initialBuilder,
    this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessDataBloc<T>, BusinessDataState>(
      builder: (context, state) {
        return switch (state) {
          // Pass context to default helper widgets
          BusinessDataInitial() =>
            initialBuilder ?? _defaultInitialWidget(context),
          BusinessDataLoading() =>
            loadingBuilder ?? _defaultLoadingWidget(context),
          BusinessDataError(:final message) =>
            errorBuilder?.call(message) ??
                _defaultErrorWidget(message, context), // Pass context here
          BusinessDataLoaded(:final data) =>
            onRefresh != null
                ? RefreshIndicator(
                    onRefresh: () async => onRefresh!(),
                    child: successBuilder(data),
                  )
                : successBuilder(data),
        };
      },
    );
  }

  // --- Helper Widgets (now accept BuildContext) ---

  Widget _defaultInitialWidget(BuildContext context) {
    // Added BuildContext
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 48),
          SizedBox(height: 16),
          Text('Select a business to view data'),
        ],
      ),
    );
  }

  Widget _defaultLoadingWidget(BuildContext context) {
    // Added BuildContext
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading business data...'),
        ],
      ),
    );
  }

  Widget _defaultErrorWidget(String message, BuildContext context) {
    // Added BuildContext
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Only show Retry button if onRefresh callback is provided
          if (onRefresh != null)
            FilledButton(
              onPressed: () {
                // Trigger the onRefresh callback, which should handle actual data re-fetching
                onRefresh!();
                // Optional: Show a temporary message that refresh is attempted
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attempting to retry...')),
                );
              },
              child: const Text('Retry'),
            )
          else // If no onRefresh, provide a general info message instead of a button
            const Text(
              'Please check your connection and try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
