import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:mime_app/detailed_view/presentation/widgets/selected_assets_options_sheet.dart';
import 'package:mime_app/detailed_view/presentation/widgets/sticker_pack_widget.dart';
import 'package:mime_app/pack_selector/bloc/pack_selector_bloc.dart';
import 'package:mime_app/pack_selector/presentation/screens/pack_select_screen.dart';

class PackDetailsScreen extends StatefulWidget {
  const PackDetailsScreen({super.key});

  @override
  State<PackDetailsScreen> createState() => _PackDetailsScreenState();
}

class _PackDetailsScreenState extends State<PackDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PackDetailsBloc, PackDetailsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final pack = state.pack;
        List<Widget> actions = [];
        String appBarTitle = pack.name;

        if (!pack.isUnassigned) {
          actions = [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.delete),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.sync),
            ),
          ];
        }

        // But if in select mode, give option to select/deselect all
        if (state.selectMode) {
          appBarTitle = '${state.selectedAssets.length}';
          bool value = state.selectedAssets.length != pack.assets.length;
          actions = [
            IconButton(
              onPressed: () async {
                for (final asset in pack.assets) {
                  context
                      .read<PackDetailsBloc>()
                      .add(AssetSelected(asset.id, value));
                }
              },
              icon: Icon(value ? Icons.select_all : Icons.deselect),
            ),
          ];
        }
        Widget body = Padding(
          padding: const EdgeInsets.all(8.0),
          child: PackDetailsWidget(pack: pack),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: actions,
          ),
          body: Stack(
            children: [body, const SelectedAssetsOptionsSheet()],
          ),
        );
      },
    );
  }
}
