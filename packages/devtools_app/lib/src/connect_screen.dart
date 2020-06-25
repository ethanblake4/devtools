// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:devtools_app/devtools.dart';
import 'package:devtools_app/src/framework/framework_core.dart';
import 'package:devtools_app/src/globals.dart';
import 'package:devtools_app/src/navigation.dart';
import 'package:devtools_app/src/theme.dart';
import 'package:devtools_app/src/url_utils.dart';
import 'package:devtools_app/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

/// The screen in the app responsible for connecting to the Dart VM.
///
/// We need to use this screen to get a guarantee that the app has a Dart VM
/// available.
class ConnectScreenBody extends StatefulWidget {
  @override
  State<ConnectScreenBody> createState() => _ConnectScreenBodyState();
}

class _ConnectScreenBodyState extends State<ConnectScreenBody> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect to a Running App',
              style: textTheme.bodyText1,
            ),
            const SizedBox(height: denseRowSpacing),
            Text(
              'Enter a URL to a running Dart or Flutter application',
              style: textTheme.caption,
            ),
            const Padding(padding: EdgeInsets.only(top: 12.0)),
            _buildTextInput(),
          ],
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    final CallbackDwell connectDebounce = CallbackDwell(_connect);

    return Row(
      children: [
        SizedBox(
          width: 350.0,
          child: TextField(
            onSubmitted: (str) => connectDebounce.invoke(),
            autofocus: true,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'http://127.0.0.1:12345/auth_code=',
            ),
            controller: controller,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20.0),
        ),
        RaisedButton(
          child: const Text('Connect'),
          onPressed: connectDebounce.invoke,
        ),
      ],
    );
  }

  Future<void> _connect() async {
    if (controller.text?.isEmpty ?? true) {
      Notifications.of(context).push(
        'Please enter a VM Service URL.',
      );
      return;
    }

    final uri = normalizeVmServiceUri(controller.text);
    final connected = await FrameworkCore.initVmService(
      '',
      explicitUri: uri,
      errorReporter: (message, error) {
        Notifications.of(context).push('$message $error');
      },
    );
    if (connected) {
      final connectedUri = serviceManager.service.connectedUri;
      unawaited(
        Navigator.pushNamed(
          context,
          routeNameWithQueryParams(context, '/', {'uri': '$connectedUri'}),
        ),
      );
      final shortUri = connectedUri.replace(path: '');
      Notifications.of(context).push(
        'Successfully connected to $shortUri.',
      );
    } else if (uri == null) {
      Notifications.of(context).push(
        'Failed to connect to the VM Service at "${controller.text}".\n'
        'The link was not valid.',
      );
    }
  }
}
