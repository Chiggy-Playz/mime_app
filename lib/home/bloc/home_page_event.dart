part of 'home_page_bloc.dart';

sealed class HomePageEvent extends Equatable {
  const HomePageEvent();

  @override
  List<Object> get props => [];
}

final class HomePageStarted extends HomePageEvent {}

final class HomePageRefreshed extends HomePageEvent {}

final class HomePageRebuild extends HomePageEvent {}