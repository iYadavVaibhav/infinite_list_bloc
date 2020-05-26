import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  // Get function
  @override
  List<Object> get props => []; 
}

class PostFetched extends PostEvent {}