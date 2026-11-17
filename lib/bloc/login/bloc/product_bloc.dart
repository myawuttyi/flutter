import 'package:bloc/bloc.dart';
//import 'package:flutter_assignment/ui/product.dart';
import 'package:flutter_bloc_auth_profile/models/products.model.dart';
import 'package:flutter_bloc_auth_profile/repo/productrepo.dart';
import 'package:meta/meta.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  ProductBloc(this.productRepository) : super(ProductInitial()) {
    on<ProductEvent>(onLoadProducts) ;
      // TODO: implement event handler
  }

 
  onLoadProducts(ProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      // Simulate a network call to fetch products
      await Future.delayed(const Duration(seconds: 2));
      final products = await productRepository.getItems();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(error: e.toString()));
    }
  }
}

