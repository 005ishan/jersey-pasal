//for with parameters
import 'package:dartz/dartz.dart';
import 'package:jerseypasal/core/error/failures.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

//for without parameters
abstract interface class UsecaseWithoutParams<SuccessType>{
  Future<Either<Failure, SuccessType>> call();
}