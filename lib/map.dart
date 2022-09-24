import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'global.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey googleMapWebViewKey = GlobalKey();
  final TextEditingController mapSearchController = TextEditingController();

  double mapProgress = 0;

  InAppWebViewController? mapInAppWebViewController;
  late PullToRefreshController mapPullToRefreshController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  wikiInitRefreshController() async {
    mapPullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(color: Colors.blue),
        onRefresh: () async {
          if (Platform.isAndroid) {
            mapInAppWebViewController?.reload();
          } else if (Platform.isIOS) {
            mapInAppWebViewController?.loadUrl(
                urlRequest:
                    URLRequest(url: await mapInAppWebViewController?.getUrl()));
          }
        });
  }

  @override
  initState() {
    super.initState();
    wikiInitRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Google Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                await mapInAppWebViewController!.goBack();
              },
              child: const Icon(Icons.arrow_back_ios_rounded),
            ),
            label: "Back",
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                if (Platform.isAndroid) {
                  mapInAppWebViewController?.reload();
                } else if (Platform.isIOS) {
                  mapInAppWebViewController?.loadUrl(
                      urlRequest: URLRequest(
                          url: await mapInAppWebViewController?.getUrl()));
                }
              },
              child: const Icon(
                CupertinoIcons.refresh,
              ),
            ),
            label: "Back",
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () async {
                await mapInAppWebViewController!.goForward();
              },
              child: const Icon(Icons.arrow_forward_ios_rounded),
            ),
            label: "Back",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: TextField(
                  controller: mapSearchController,
                  onSubmitted: (val) async {
                    Uri uri = Uri.parse(val);
                    if (uri.scheme.isEmpty) {
                      uri = Uri.parse("https://www.google.co.in/search?q=$val");
                    }
                    await mapInAppWebViewController!
                        .loadUrl(urlRequest: URLRequest(url: uri));
                  },
                  decoration: InputDecoration(
                    hintText: "Search on web...",
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blue,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              ),
            ),
          ),
          (mapProgress < 1)
              ? LinearProgressIndicator(
                  value: mapProgress,
                  color: Colors.green[700],
                )
              : Container(),
          Expanded(
            flex: 10,
            child: InAppWebView(
              key: googleMapWebViewKey,
              pullToRefreshController: mapPullToRefreshController,
              onWebViewCreated: (controller) {
                mapInAppWebViewController = controller;
              },
              initialOptions: options,
              initialUrlRequest: URLRequest(
                  url: Uri.parse(
                      "https://www.google.co.in/search?q=$lat,$long")),
              onLoadStart: (controller, uri) {
                setState(() {
                  mapSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              onLoadStop: (controller, uri) {
                mapPullToRefreshController.endRefreshing();
                setState(() {
                  mapSearchController.text =
                      "${uri!.scheme}://${uri.host}${uri.path}";
                });
              },
              androidOnPermissionRequest:
                  (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
              onProgressChanged: (controller, val) {
                if (val == 100) {
                  mapPullToRefreshController.endRefreshing();
                }
                setState(() {
                  mapProgress = val / 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
