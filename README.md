# RuffleMobile
Ruffle is an emulator for the Adobe Flash Player, written in Rust. Unlike the original Flash Player, you can build an HTML5 version so it doesn't get blocked by browser like Flash does.

Because this is HTML5, it also means you can display it in a web view on mobile devices, which is exactly what I'm doing here with WKWebView. I have a local web server on the device that uses GCDWebServer to serve content to the web view.

Right now this app allows you to pick a .swf file from Files to run in the Ruffle player, and that's it.
