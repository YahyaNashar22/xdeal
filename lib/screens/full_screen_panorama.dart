import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class FullScreenPanorama extends StatelessWidget {
  final String imageUrl;
  const FullScreenPanorama({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Black background looks best for 360 views
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true, // Makes the 360 view fill the whole screen
      body: PanoramaViewer(
        zoom: 1,
        interactive: true,
        child: Image.network(imageUrl),
      ),
    );
  }
}
