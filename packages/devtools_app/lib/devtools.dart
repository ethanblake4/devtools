// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'src/config_specific/framework_initialize/framework_initialize.dart';
import 'src/preferences.dart';

export 'src/app.dart';
export 'src/notifications.dart';
export 'src/preferences.dart';
export 'src/table.dart';
export 'src/table_data.dart';

/// The DevTools application version.
// This version should only be updated by running tools/update_version.sh
// that updates all versions for DevTools.
// Note: a regexp in tools/update_version.sh matches the following line so
// if you change it you must also modify tools/update_version.sh.
const String version = '0.8.0-dev.1';

Future<PreferencesController> initDevTools() async {
  final preferences = PreferencesController();
  // Wait for preferences to load before rendering the app to avoid a flash of
  // content with the incorrect theme.
  await preferences.init();

  await initializeFramework();

  return preferences;
  // defaultScreens
}
