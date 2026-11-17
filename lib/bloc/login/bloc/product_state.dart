part of 'product_bloc.dart';
//import 'package:flutter_bloc_auth_profile/models/product.dart'; // Adjust path to where you saved Product

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}
final class ProductLoading extends ProductState {}
final class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded({required this.products});
}
final class ProductError extends ProductState {
  final String error;

  ProductError({required this.error});
}