part of 'new_pack_bloc.dart';

sealed class NewPackEvent extends Equatable {
  const NewPackEvent();

  @override
  List<Object> get props => [];
}

class PackSaved extends NewPackEvent {
  const PackSaved(this.name, this.trayIconPath);

  final String name;
  final String trayIconPath;

  @override
  List<Object> get props => [name, trayIconPath];
}