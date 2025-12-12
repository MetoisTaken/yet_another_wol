import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yet_another_wol/src/features/devices/presentation/device_list_screen.dart';
import 'package:yet_another_wol/src/core/services/tray_service.dart';
import 'package:yet_another_wol/src/features/widget/widget_service.dart';
import 'package:yet_another_wol/src/features/widget/quick_actions_service.dart';
import 'package:yet_another_wol/src/core/services/window_service.dart';
import 'package:yet_another_wol/src/core/services/notification_service.dart';

class WolApp extends ConsumerWidget {
  const WolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize background services
    ref.watch(trayServiceProvider);
    ref.watch(widgetServiceProvider);
    ref.watch(quickActionsServiceProvider);
    ref.watch(windowServiceProvider);
    ref.watch(notificationServiceProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yet Another WoL',
      theme: FlexThemeData.light(
        scheme: FlexScheme.brandBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.brandBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: const DeviceListScreen(),
    );
  }
}
