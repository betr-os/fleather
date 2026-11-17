import 'dart:ui' show PointerDeviceKind;

import 'package:fleather/fleather.dart';
import 'package:fleather/src/widgets/checkbox.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

FleatherController _controller(String text, [Map<String, dynamic>? line]) =>
    FleatherController(
      document: ParchmentDocument.fromDelta(
        Delta()
          ..insert(text)
          ..insert('\n', line),
      ),
    );

Widget _host(Widget child) => MaterialApp(
      localizationsDelegates: FleatherLocalizations.localizationsDelegates,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('cursor color and width can be set', (tester) async {
    final controller = _controller('Text');
    await tester.pumpWidget(_host(FleatherEditor(
      controller: controller,
      autofocus: true,
      cursorColor: const Color(0xff123456),
      cursorWidth: 1,
    )));
    await tester.pump();
    final raw = tester.widget<RawEditor>(find.byType(RawEditor));
    expect(raw.cursorStyle.width, 1);
    expect(raw.cursorStyle.color, const Color(0xff123456));
  });

  testWidgets('a non-scrolling editor can select text', (tester) async {
    final controller = _controller('Selectable words here');
    await tester.pumpWidget(_host(FleatherEditor(
      controller: controller,
      readOnly: true,
      scrollable: false,
    )));
    final start = tester.getTopLeft(find.byType(FleatherEditor));
    final gesture = await tester.startGesture(start + const Offset(4, 8),
        kind: PointerDeviceKind.mouse);
    await tester.pump();
    await gesture.moveTo(start + const Offset(90, 8));
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(controller.selection.isCollapsed, isFalse);
  });

  testWidgets('checklist items can be ticked in a read-only editor on request',
      (tester) async {
    for (final toggles in [false, true]) {
      final controller = _controller('Ladder', ParchmentAttribute.cl.toJson());
      await tester.pumpWidget(_host(FleatherEditor(
        controller: controller,
        readOnly: true,
        checklistTogglesWhenReadOnly: toggles,
      )));
      await tester.tap(find.byType(FleatherCheckbox));
      await tester.pump();
      final checked = controller.document
          .toDelta()
          .toList()
          .last
          .attributes?[ParchmentAttribute.checked.key];
      expect(checked == true, toggles);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('checklist boxes can be built by the app', (tester) async {
    final controller = _controller('Ladder', ParchmentAttribute.cl.toJson());
    final seen = <bool>[];
    await tester.pumpWidget(_host(FleatherEditor(
      controller: controller,
      readOnly: true,
      checklistTogglesWhenReadOnly: true,
      checkboxBuilder: (context, value, onChanged) {
        seen.add(value);
        return GestureDetector(
          key: const ValueKey('box'),
          behavior: HitTestBehavior.opaque,
          onTap: onChanged == null ? null : () => onChanged(!value),
          child: const SizedBox.square(dimension: 16),
        );
      },
    )));
    expect(find.byType(FleatherCheckbox), findsNothing);
    await tester.tap(find.byKey(const ValueKey('box')));
    await tester.pump();
    expect(seen.first, isFalse);
    expect(seen.last, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
