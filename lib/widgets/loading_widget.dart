import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: const [Colors.blueAccent]),
      ),
    );
  }
}