// Imports the Flutter Driver API
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:screenshots/config.dart';
import 'package:screenshots/capture_screen.dart';

void main() {
  final Map config = Config().config;

  group('Screenshots', () {
    // First, define the Finders. We can use these to locate Widgets from the
    // test suite. Note: the Strings provided to the `byValueKey` method must
    // be the same as the Strings we used for the Keys in step 1.

    FlutterDriver driver;


    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('screenshot', () async {
      await screenshot(driver, config, 'main_app');
    });
  });
}
