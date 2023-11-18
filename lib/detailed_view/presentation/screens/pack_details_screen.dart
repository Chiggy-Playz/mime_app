import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:mime_app/detailed_view/presentation/widgets/sticker_pack_widget.dart';
import 'package:mime_app/pack_selector/bloc/pack_selector_bloc.dart';
import 'package:mime_app/pack_selector/presentation/screens/pack_select_screen.dart';
import 'package:user_repository/user_repository.dart';

class PackDetailsScreen extends StatefulWidget {
  const PackDetailsScreen({super.key, required this.pack});

  static Route<void> route(Pack pack) {
    return MaterialPageRoute(
      builder: (_) => PackDetailsScreen(
        pack: pack,
      ),
    );
  }

  final Pack pack;

  @override
  State<PackDetailsScreen> createState() => _PackDetailsScreenState();
}

class _PackDetailsScreenState extends State<PackDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackDetailsBloc, PackDetailsState>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar( 
              title: Text(widget.pack.name),
              actions: widget.pack.isUnassigned
                  ? null
                  : [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.sync),
                      ),
                    ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PackDetailsWidget(pack: widget.pack),
            ),
            floatingActionButton: state.selectMode
                ? FloatingActionButton(
                    onPressed: () async {
                      final packSelectorBloc = PackSelectorBloc(
                        RepositoryProvider.of<AssetsRepository>(context),
                        RepositoryProvider.of<UserRepository>(context),
                      );

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: packSelectorBloc,
                            child: const PackSelectorScreen(),
                          ),
                        ),
                      );

                    },
                    child: const Icon(Icons.add),
                  )
                : null);
      },
    );
  }
}
