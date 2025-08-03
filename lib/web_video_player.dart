import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebVideoPlayer {
  static void registerIframe(String iframeId, String youtubeVideoId) {
    final String videoUrl =
        'https://www.youtube.com/embed/$youtubeVideoId?autoplay=1&rel=0';
    ui_web.platformViewRegistry.registerViewFactory(
      iframeId,
      (int viewId) => html.IFrameElement()
        ..src = videoUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true,
    );
  }
}
