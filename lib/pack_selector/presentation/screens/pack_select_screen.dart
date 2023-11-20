import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/new_pack/bloc/new_pack_bloc.dart';
import 'package:mime_app/pack_selector/bloc/pack_selector_bloc.dart';
import 'package:mime_app/new_pack/widgets/new_pack_bottom_modal_widget.dart';
import 'package:user_repository/user_repository.dart';

class PackSelectorScreen extends StatefulWidget {
  const PackSelectorScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const PackSelectorScreen(),
    );
  }

  @override
  State<PackSelectorScreen> createState() => _PackSelectorScreenState();
}

class _PackSelectorScreenState extends State<PackSelectorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PackSelectorBloc>().add(const PackSelectorStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackSelectorBloc, PackSelectorState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Select pack(s)"),
          ),
          body: ListView.builder(
            itemCount: 1 + state.allPacks.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("New pack"),
                  onTap: newPackClicked,
                );
              }
              index -= 1;
              final pack = state.allPacks[index];
              return CheckboxListTile(
                value: state.selectedPacks.contains(pack),
                title: Text(pack.name),
                subtitle: Text("${pack.assetCount} stickers"),
                onChanged: (value) {
                  BlocProvider.of<PackSelectorBloc>(context)
                      .add(PackSelected(pack, value ?? false));
                },
              );
            },
          ),
          floatingActionButton: state.selectedPacks.isEmpty
              ? null
              : FloatingActionButton(
                  child: const Icon(Icons.done),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
        );
      },
    );
  }

  Future<void> newPackClicked() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => NewPackBloc(
          RepositoryProvider.of<AssetsRepository>(context),
          RepositoryProvider.of<UserRepository>(context),
        ),
        child: const Wrap(children: [NewPackWidget()]),
      ),
      isScrollControlled: true,
    );
  }
}
