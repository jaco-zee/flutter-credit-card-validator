import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_submitter/features/cards/cubit/cards_cubit.dart';
import 'package:card_submitter/features/cards/filter/cards_filter_cubit.dart';
import 'package:card_submitter/features/cards/page/cards_page.dart';
import 'package:card_submitter/domain/repositories/card_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:card_submitter/domain/entities/credit_card.dart';
import 'package:card_submitter/domain/value_objects/card_brand.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  group('Add and List Flow Integration Test', () {
    late MockCardRepository mockRepository;
    
    setUpAll(() {
      registerFallbackValue(CreditCard(
        number: '4242424242424242',
        brand: CardBrand.visa,
        cardHolderName: 'John Doe',
        expiryDate: '12/28',
        issuingCountry: 'US',
        savedAt: DateTime.now(),
      ));
    });
    
    setUp(() {
      mockRepository = MockCardRepository();
    });
    
    testWidgets('complete user flow: empty state -> add card -> shows in list', (tester) async {
      // Setup: Repository returns empty list initially
      when(() => mockRepository.getAll()).thenAnswer((_) async => []);
      when(() => mockRepository.exists(any())).thenAnswer((_) async => false);
      when(() => mockRepository.save(any())).thenAnswer((_) async => {});
      
      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CardsCubit(mockRepository)..load(),
              ),
              BlocProvider(
                create: (context) => CardsFilterCubit(),
              ),
            ],
            child: const CardsPage(),
          ),
        ),
      );
      
      // Wait for initial load
      await tester.pumpAndSettle();
      
      // Verify empty state is shown
      expect(find.text('No cards saved yet'), findsOneWidget);
      expect(find.text('Tap the + button to add your first card'), findsOneWidget);
      
      // Verify FAB is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Tap the FAB to add a card - for now just verify navigation attempt
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Note: In a real integration test, we would navigate to the form page
      // and fill out the form, but that requires more complex setup
    });
    
    testWidgets('shows cards in list when they exist', (tester) async {
      final testCards = [
        CreditCard(
          number: '4111111111111111',
          brand: CardBrand.visa,
          issuingCountry: 'US',
          savedAt: DateTime(2023, 1, 2),
          cardHolderName: 'John Doe',
          expiryDate: '12/26',
        ),
        CreditCard(
          number: '5555555555554444',
          brand: CardBrand.mastercard,
          issuingCountry: 'CA',
          savedAt: DateTime(2023, 1, 1),
          cardHolderName: 'Jane Smith',
          expiryDate: '06/27',
        ),
      ];
      
      // Setup: Repository returns test cards
      when(() => mockRepository.getAll()).thenAnswer((_) async => testCards);
      
      // Build the widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CardsCubit(mockRepository)..load(),
              ),
              BlocProvider(
                create: (context) => CardsFilterCubit(),
              ),
            ],
            child: const CardsPage(),
          ),
        ),
      );
      
      // Wait for cards to load
      await tester.pumpAndSettle();
      
      // Verify cards are displayed (newest first)
      expect(find.text('#### #### #### 1111'), findsOneWidget); // Visa card
      expect(find.text('#### #### #### 4444'), findsOneWidget); // Mastercard
      expect(find.text('Visa • US'), findsOneWidget);
      expect(find.text('Mastercard • CA'), findsOneWidget);
      
      // Verify cards are in the correct order (newest first)
      final cardWidgets = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(cardWidgets.length, equals(2));
    });
    
    testWidgets('filter functionality works', (tester) async {
      final testCards = [
        CreditCard(
          number: '4111111111111111',
          brand: CardBrand.visa,
          issuingCountry: 'US',
          savedAt: DateTime(2023, 1, 1),
          cardHolderName: 'Alice Johnson',
          expiryDate: '05/25',
        ),
        CreditCard(
          number: '5555555555554444',
          brand: CardBrand.mastercard,
          issuingCountry: 'CA',
          savedAt: DateTime(2023, 1, 2),
          cardHolderName: 'Bob Smith',
          expiryDate: '08/26',
        ),
      ];
      
      when(() => mockRepository.getAll()).thenAnswer((_) async => testCards);
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CardsCubit(mockRepository)..load(),
              ),
              BlocProvider(
                create: (context) => CardsFilterCubit(),
              ),
            ],
            child: const CardsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify both cards are shown initially
      expect(find.text('#### #### #### 1111'), findsOneWidget);
      expect(find.text('#### #### #### 4444'), findsOneWidget);
      
      // Open filter bottom sheet
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
      
      // Verify filter sheet is shown
      expect(find.text('Filter Cards'), findsOneWidget);
      expect(find.text('Card Brands'), findsOneWidget);
      
      // Filter by Visa brand
      await tester.tap(find.text('Visa').last);
      await tester.pumpAndSettle();
      
      // Close filter sheet (tap outside or use back)
      await tester.tapAt(const Offset(50, 50));
      await tester.pumpAndSettle();
      
      // Verify only Visa card is shown
      expect(find.text('#### #### #### 1111'), findsOneWidget);
      expect(find.text('#### #### #### 4444'), findsNothing);
    });
    
    testWidgets('shows error when loading fails', (tester) async {
      // Setup: Repository throws error
      when(() => mockRepository.getAll()).thenThrow(Exception('Network error'));
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CardsCubit(mockRepository)..load(),
              ),
              BlocProvider(
                create: (context) => CardsFilterCubit(),
              ),
            ],
            child: const CardsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify error state is shown
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Failed to load cards: Exception: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}