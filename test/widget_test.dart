// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:driveit_app/app/app.dart';
import 'package:driveit_app/core/config/app_config.dart';
import 'package:driveit_app/features/vehicles/data/in_memory_vehicle_data_source.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_repository_impl.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicles_list_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  const config = AppConfig(apiBaseUrl: 'http://localhost:8080');

  Future<void> pumpApp(
    WidgetTester tester, {
    required VehicleRepository repository,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppConfig>.value(value: config),
          Provider<VehicleRepository>.value(value: repository),
        ],
        child: const DriveItApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> openVehiclesTab(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.directions_car_filled_outlined));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> waitForFinder(Finder finder, WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) return;
    }
  }

  Future<void> openVehicleDetails(WidgetTester tester) async {
    final infoButton = find.byIcon(Icons.info_outline).first;
    await tester.tap(infoButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
  }

  Future<void> scrollDetails(WidgetTester tester, double offsetY) async {
    final scrollable = find.byType(CustomScrollView).first;
    await tester.drag(scrollable, Offset(0, offsetY));
    await tester.pumpAndSettle();
  }

  testWidgets('navigates to vehicles tab and renders seeded vehicles', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);

    expect(find.text('Recent events'), findsOneWidget);

    await openVehiclesTab(tester);

    expect(find.byType(VehiclesListPage), findsOneWidget);
    final bottomNav = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(bottomNav.currentIndex, 1);
  });

  testWidgets('allows editing a vehicle via manage sheet', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    final initialVehicles = await repository.fetchVehicles();
    final targetVehicleId = initialVehicles.first.id;

    final manageButtons = find.widgetWithText(FilledButton, 'Manage');
    await waitForFinder(manageButtons, tester);
    expect(manageButtons, findsNWidgets(2));

    await tester.tap(manageButtons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();

    final displayField = find.byType(TextField).first;
    await tester.enterText(displayField, 'Daily Driver Updated');
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final updatedVehicles = await repository.fetchVehicles();
    final updatedVehicle = updatedVehicles.firstWhere(
      (vehicle) => vehicle.id == targetVehicleId,
    );
    expect(updatedVehicle.displayName, 'Daily Driver Updated');
    expect(find.widgetWithText(FilledButton, 'Manage'), findsNWidgets(2));
    expect(find.text('Vehicle updated'), findsOneWidget);
  });

  testWidgets('allows deleting a vehicle with confirmation', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    final manageButtons = find.widgetWithText(FilledButton, 'Manage');
    await waitForFinder(manageButtons, tester);
    expect(manageButtons, findsNWidgets(2));

    await tester.tap(manageButtons.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.text('Delete vehicle'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Weekend Ride'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Manage'), findsNWidgets(1));
    expect(find.textContaining('deleted'), findsOneWidget);
  });

  testWidgets('opens vehicle details from info button', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    await openVehicleDetails(tester);
    expect(find.text('Vehicle Overview'), findsOneWidget);
    await scrollDetails(tester, -400);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Photo album'), findsOneWidget);
    expect(find.text('Add photo'), findsWidgets);
    expect(find.text('Add document'), findsOneWidget);
  });

  testWidgets('opens vehicle details when tapping vehicle tile', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    await tester.tap(find.text('Daily Driver').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.text('Vehicle Overview'), findsOneWidget);
    await scrollDetails(tester, -400);
    expect(find.text('Documents'), findsOneWidget);
  });

  testWidgets('adds a photo through the vehicle album sheet', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    await openVehicleDetails(tester);
    mockFilePicker(
      Uint8List.fromList(List<int>.generate(20, (index) => index)),
      name: 'test.jpg',
    );
    await tester.scrollUntilVisible(
      find.text('Add photo'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add photo').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Files'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final snackTextFinder = find.descendant(
      of: find.byType(SnackBar),
      matching: find.byType(Text),
    );
    expect(snackTextFinder, findsOneWidget);
    final snackText = tester.widget<Text>(snackTextFinder);
    expect(
      snackText.data,
      anyOf('Photo added to album', 'Photos added to album'),
    );
  });

  testWidgets('attaches a document through the details page', (
    WidgetTester tester,
  ) async {
    final repository = VehicleRepositoryImpl(InMemoryVehicleDataSource());
    await pumpApp(tester, repository: repository);
    await openVehiclesTab(tester);

    await openVehicleDetails(tester);
    await tester.scrollUntilVisible(
      find.text('Add document'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add document').first);
    await tester.pumpAndSettle();

    mockFilePicker(
      Uint8List.fromList(List<int>.generate(20, (index) => index + 5)),
      name: 'report.pdf',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Inspection Report',
    );

    await tester.tap(find.text('Select file'));
    await tester.pump();
    expect(find.textContaining('report.pdf'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Inspection Report'), findsWidgets);
  });
}

FilePickerResult _buildSingleFileResult({
  required String name,
  required Uint8List bytes,
}) {
  return FilePickerResult([
    PlatformFile(name: name, size: bytes.length, bytes: bytes),
  ]);
}

void mockFilePicker(Uint8List bytes, {String name = 'upload.dat'}) {
  FilePicker? original;
  try {
    original = FilePicker.platform;
  } catch (_) {}
  FilePicker.platform = _TestFilePicker(
    _buildSingleFileResult(name: name, bytes: bytes),
  );
  addTearDown(() {
    if (original != null) {
      FilePicker.platform = original;
    } else {
      FilePicker.platform = _TestFilePicker(null);
    }
  });
}

class _TestFilePicker extends FilePicker {
  _TestFilePicker(this._result);

  final FilePickerResult? _result;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => _result;

  @override
  Future<bool?> clearTemporaryFiles() async => true;

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async => null;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async => null;
}
