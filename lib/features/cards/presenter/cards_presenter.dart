import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../../core/widgets/loading_state_widget.dart';
import '../../../domain/entities/credit_card.dart';
import '../cubit/cards_cubit.dart';
import '../cubit/cards_state.dart';
import '../filter/cards_filter_cubit.dart';
import '../filter/cards_filter_state.dart';
import '../widgets/card_details_bottom_sheet.dart';
import '../widgets/mini_credit_card_widget.dart';

class CardsPresenter extends StatelessWidget {
  const CardsPresenter({
    super.key,
    required this.onAddCard,
    required this.onOpenFilter,
  });
  
  final VoidCallback onAddCard;
  final VoidCallback onOpenFilter;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardsCubit, CardsState>(
      listener: (context, state) {
        // Show snackbar for operation results
        if (state.lastOperationStatus == CardsStatus.success && state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.green,
            ),
          );
          context.read<CardsCubit>().clearMessage();
        } else if (state.lastOperationStatus == CardsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
          context.read<CardsCubit>().clearMessage();
        }
      },
      builder: (context, cardsState) {
        context.read<CardsFilterCubit>().updateBaseCards(cardsState.cards);
        
        return BlocBuilder<CardsFilterCubit, CardsFilterState>(
          builder: (context, filterState) {
            if (cardsState.status == CardsStatus.initial || cardsState.status == CardsStatus.loading) {
              return const LoadingStateWidget(
                message: 'Loading your cards...',
              );
            }
            
            if (cardsState.status == CardsStatus.error) {
              return ErrorStateWidget(
                title: 'Oops! Something went wrong',
                message: cardsState.errorMessage,
                onRetry: () => context.read<CardsCubit>().load(),
              );
            }
            
            final cardsToShow = filterState.filteredCards;
            
            if (cardsToShow.isEmpty) {
              return _buildEmptyState(context, filterState);
            }
            
            return _buildCardsList(context, cardsToShow);
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context, CardsFilterState filterState) {
    final hasActiveFilters = filterState.query.isNotEmpty ||
        filterState.selectedBrands.isNotEmpty ||
        filterState.selectedCountries.isNotEmpty;
    
    if (hasActiveFilters) {
      return EmptyStateWidget(
        icon: Icons.filter_alt_off,
        iconColor: Colors.orange.shade400,
        title: 'No matching cards',
        message: 'Try adjusting your filters to see more results',
        primaryAction: ElevatedButton.icon(
          onPressed: () => context.read<CardsFilterCubit>().clearAll(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear All Filters'),
        ),
      );
    }
    
    return EmptyStateWidget(
      icon: Icons.credit_card_outlined,
      iconColor: Colors.blue.shade400,
      title: 'No cards saved yet',
      message: 'Add your first credit card to get started',
      primaryAction: ElevatedButton.icon(
        onPressed: onAddCard,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Your First Card'),
      ),
    );
  }
  
  Widget _buildCardsList(BuildContext context, List<CreditCard> cards) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: cards.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == cards.length) {
            // Bottom padding item
            return const SizedBox(height: 100);
          }
          
          final card = cards[index];
          return MiniCreditCardWidget(
            card: card,
            onTap: () => _showCardDetails(context, card),
          );
        },
      ),
    );
  }
  
  void _showCardDetails(BuildContext context, CreditCard card) {
    CardDetailsBottomSheet.show(
      context,
      card,
      onDelete: () {
        Navigator.of(context).pop();
        _showDeleteConfirmation(context, card);
      },
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text(
            'Are you sure you want to delete this card?\n\n${card.maskedNumber}\n${card.brand.displayName}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CardsCubit>().deleteCard(card.number);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}