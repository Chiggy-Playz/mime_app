import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/pack_selector/bloc/pack_selector_bloc.dart';
import 'package:mime_app/pack_selector/presentation/widgets/new_pack_bottom_modal_widget.dart';

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
                value: state.selectedPacks.contains(pack.packId),
                onChanged: (value) {},
                title: Text(pack.name),
                subtitle: Text("${pack.assetCount} stickers"),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> newPackClicked() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => const Wrap(children: [NewPackWidget()]),
      isScrollControlled: true,
    );
  }
}
