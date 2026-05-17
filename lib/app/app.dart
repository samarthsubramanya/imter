import 'package:flutter/material.dart';

import '../features/about/about_screen.dart';
import '../features/converter/converter_controller.dart';
import '../features/converter/converter_screen.dart';
import '../features/learn/learn_screen.dart';
import '../services/codec/codec_registry.dart';
import '../services/codec/dart_image_adapter.dart';
import '../services/estimate/image_analyzer.dart';
import '../services/estimate/size_estimator.dart';
import '../services/files/file_picker_service.dart';
import 'app_info.dart';
import 'theme.dart';

class ImterApp extends StatefulWidget {
  const ImterApp({super.key});

  @override
  State<ImterApp> createState() => _ImterAppState();
}

class _ImterAppState extends State<ImterApp> {
  late final ConverterController _controller;
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ConverterController(
      codecRegistry: CodecRegistry([DartImageAdapter()]),
      filePickerService: FilePickerService(),
      imageAnalyzer: ImageAnalyzer(),
      sizeEstimator: SizeEstimator(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: buildImterTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                labelType: NavigationRailLabelType.all,
                minWidth: 92,
                leading: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AppInfo.logoAsset,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.compare_arrows_rounded),
                    selectedIcon: Icon(Icons.compare_arrows_rounded),
                    label: Text('Convert'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book_rounded),
                    label: Text('Learn'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.info_outline_rounded),
                    selectedIcon: Icon(Icons.info_rounded),
                    label: Text('About'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    ConverterScreen(controller: _controller),
                    const LearnScreen(),
                    const AboutScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
