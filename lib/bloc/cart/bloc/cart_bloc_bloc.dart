import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_auth_profile/models/products.model.dart';

part 'cart_bloc_event.dart';
part 'cart_bloc_state.dart';

class CartBlocBloc extends Bloc<CartBlocEvent, CartBlocState> {
  CartBlocBloc() : super(const CartBlocState()) {
    on<AddToCart>(_onAddToCart);
    on<IncrementCartItem>(_onIncrementItem);
    on<DecrementCartItem>(_onDecrementItem);
    on<RemoveFromCart>(_onRemoveItem);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartBlocState> emit) {
    final updatedItems = List<CartItem>.from(state.items);
    final index =
        updatedItems.indexWhere((i) => i.product.id == event.product.id);

    if (index >= 0) {
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity + 1,
      );
    } else {
      updatedItems.add(CartItem(product: event.product, quantity: 1));
    }

    emit(CartBlocState(items: updatedItems));
  }

  void _onIncrementItem(IncrementCartItem event, Emitter<CartBlocState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == event.productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    emit(CartBlocState(items: updatedItems));
  }

  void _onDecrementItem(DecrementCartItem event, Emitter<CartBlocState> emit) {
    final updatedItems = <CartItem>[];

    for (final item in state.items) {
      if (item.product.id == event.productId) {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
      } else {
        updatedItems.add(item);
      }
    }

    emit(CartBlocState(items: updatedItems));
  }

  void _onRemoveItem(RemoveFromCart event, Emitter<CartBlocState> emit) {
    final updatedItems = state.items
        .where((item) => item.product.id != event.productId)
        .toList();

    emit(CartBlocState(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartBlocState> emit) {
    emit(const CartBlocState(items: []));
  }
}