part of 'new_pack_bloc.dart';

sealed class NewPackState extends Equatable {
  const NewPackState();
  
  @override
  List<Object> get props => [];
}

final class NewPackInitial extends NewPackState {}

final class NewPackLoading extends NewPackState {}

final class NewPackSuccess extends NewPackState {}

final class PackNameConflict extends NewPackState {}

final class DatabaseError extends NewPackState {}

final class UnknownError extends NewPackState {}