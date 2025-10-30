// DeenFlow Widget Tests
// Tests for the Islamic habit tracker app functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deen_flow/main.dart';

void main() {
  group('DeenFlow App Tests', () {
    testWidgets('App builds and shows DeenFlow title', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(DeenFlowApp());

      // Verify the app title appears
      expect(find.text('DeenFlow'), findsOneWidget);
      
      // Verify the vibe check section appears
      expect(find.text('Vibe Check'), findsOneWidget);
      
      // Verify the tagline appears
      expect(find.text('Your Ibadah Streak is on Lock 🔒'), findsOneWidget);
    });

    testWidgets('Shows pre-populated Islamic habits', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());

      // Verify the three core Islamic habits are present
      expect(find.text('Fajr Salah on Time'), findsOneWidget);
      expect(find.text('Read 1 Page of Quran'), findsOneWidget);
      expect(find.text('30 Seconds of Dhikr'), findsOneWidget);
      
      // Verify the "Today's Ibadah" section header
      expect(find.text('Today\'s Ibadah'), findsOneWidget);
    });

    testWidgets('Settings and Squads navigation work', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());

      // Verify settings icon exists
      expect(find.byIcon(Icons.settings), findsOneWidget);
      
      // Verify Squads button exists
      expect(find.text('Squads'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('Habit completion interaction works', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());
      
      // Find habit completion buttons (circular outline icons)
      final habitButtons = find.byIcon(Icons.circle_outlined);
      expect(habitButtons, findsWidgets);
      
      // Tap first habit completion button
      await tester.tap(habitButtons.first);
      await tester.pumpAndSettle();
      
      // Should show completion animation/snackbar
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Streak counters display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());

      // Verify streak text appears (should show "7 Day Streak" from highest habit)
      expect(find.textContaining('Day Streak'), findsOneWidget);
      
      // Verify individual habit streaks appear
      expect(find.textContaining('days'), findsWidgets);
      
      // Verify fire icon for streaks
      expect(find.byIcon(Icons.local_fire_department), findsWidgets);
    });
  });

  group('Navigation Tests', () {
    testWidgets('Settings screen navigation', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());

      // Tap settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Activate Wake-Up Notification'), findsOneWidget);
    });

    testWidgets('Squads screen navigation', (WidgetTester tester) async {
      await tester.pumpWidget(DeenFlowApp());

      // Tap Squads button
      await tester.tap(find.text('Squads'));
      await tester.pumpAndSettle();

      // Verify we're on squads screen
      expect(find.text('Squads Leaderboard'), findsOneWidget);
      expect(find.text('Weekly Challenge'), findsOneWidget);
      expect(find.text('Leaderboard'), findsOneWidget);
    });
  });
}
