import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class Failure extends Equatable {
  final List properties;

  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<Object> get props => [properties];
}
