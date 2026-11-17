part of 'cart_bloc_bloc.dart';

sealed class CartBlocEvent extends Equatable {
  const CartBlocEvent();

  @override
  List<Object> get props => [];
}

final class AddToCart extends CartBlocEvent {
  final Product product;
  const AddToCart(this.product);

  @override
  List<Object> get props => [product];
}

final class IncrementCartItem extends CartBlocEvent {
  final int productId;
  const IncrementCartItem(this.productId);

  @override
  List<Object> get props => [productId];
}

final class DecrementCartItem extends CartBlocEvent {
  final int productId;
  const DecrementCartItem(this.productId);

  @override
  List<Object> get props => [productId];
}

final class RemoveFromCart extends CartBlocEvent {
  final int productId;
  const RemoveFromCart(this.productId);

  @override
  List<Object> get props => [productId];
}

final class ClearCart extends CartBlocEvent {
  const ClearCart();
}