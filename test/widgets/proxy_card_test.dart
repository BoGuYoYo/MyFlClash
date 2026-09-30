import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _FakeSetupAction extends SetupAction {
  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async => true;
}

void main() {
  testWidgets('ProxyCard displays star button and toggles favorite status', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'test');
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        setupActionProvider.overrideWith(() => _FakeSetupAction()),
      ],
    );
    addTearDown(container.dispose);

    const proxy = Proxy(name: 'Node-1', type: 'ss');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: Scaffold(
            body: ProxyCard(
              groupName: 'PROXY',
              testUrl: 'http://test',
              proxy: proxy,
              groupType: GroupType.Selector,
              type: ProxyCardType.expand,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially unfavorited: star_outline_rounded icon
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);

    // Tap favorite button
    await tester.tap(find.byIcon(Icons.star_outline_rounded));
    await tester.pumpAndSettle();

    // Now favorited: star_rounded icon
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsNothing);
    expect(container.read(profilesProvider).single.favoriteProxies, ['Node-1']);

    // Tap again to unfavorite
    await tester.tap(find.byIcon(Icons.star_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(container.read(profilesProvider).single.favoriteProxies, isEmpty);
  });
}
