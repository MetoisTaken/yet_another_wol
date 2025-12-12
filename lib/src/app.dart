import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // iOS: Static theme only. Bypass dynamic/system theme logic.
    if (Platform.isIOS) {
      return const _WolMaterialApp();
    }

    // macOS: Native MethodChannel for Accent Color
    if (Platform.isMacOS) {
      const channel = MethodChannel('com.yawol.macos/accent');
      return FutureBuilder<int?>(
        // Fetch color once on app start.
        // Note: Does not auto-update if changed while running, requires restart or polling.
        future: channel.invokeMethod<int>('getAccentColor'),
        builder: (context, snapshot) {
          ColorScheme? lightScheme;
          ColorScheme? darkScheme;

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              final int colorValue = snapshot.data!;
              final Color accent = Color(colorValue);

              lightScheme = ColorScheme.fromSeed(
                seedColor: accent,
                brightness: Brightness.light,
              );
              darkScheme = ColorScheme.fromSeed(
                seedColor: accent,
                brightness: Brightness.dark,
              );
            } else {}
          }

          return _WolMaterialApp(
            lightScheme: lightScheme,
            darkScheme: darkScheme,
          );
        },
      );
    }

    // Android & Others: Use Dynamic Color
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return _WolMaterialApp(
          lightScheme: lightDynamic,
          darkScheme: darkDynamic,
        );
      },
    );
  }
}

class _WolMaterialApp extends StatelessWidget {
  const _WolMaterialApp({this.lightScheme, this.darkScheme});

  final ColorScheme? lightScheme;
  final ColorScheme? darkScheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yet Another WoL',
      theme: FlexThemeData.light(
        scheme: FlexScheme.brandBlue,
        colorScheme: lightScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useMaterial3Typography: true,
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
        colorScheme: darkScheme,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useMaterial3Typography: true,
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
