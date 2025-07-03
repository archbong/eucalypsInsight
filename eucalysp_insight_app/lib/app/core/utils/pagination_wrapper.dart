// business-app/eucalypsInsight/eucalysp_insight_app/lib/core/utils/pagination_wrapper.dart
import 'package:flutter/material.dart';

class PaginationWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;

  const PaginationWrapper({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.hasMore,
    this.loadingWidget,
  });

  @override
  State<PaginationWrapper> createState() => _PaginationWrapperState();
}

class _PaginationWrapperState extends State<PaginationWrapper> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && widget.hasMore) {
        _isLoading = true;
        widget.onLoadMore().then((_) {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.child,
          ),
        ),
        if (_isLoading)
          widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
