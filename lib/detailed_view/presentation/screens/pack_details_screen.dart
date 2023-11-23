import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/extensions/build_context_extensions.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:mime_app/detailed_view/presentation/widgets/selected_assets_options_sheet.dart';
import 'package:mime_app/detailed_view/presentation/widgets/sticker_pack_widget.dart';

class PackDetailsScreen extends StatefulWidget {
  const PackDetailsScreen({super.key});

  @override
  State<PackDetailsScreen> createState() => _PackDetailsScreenState();
}

class _PackDetailsScreenState extends State<PackDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PackDetailsBloc, PackDetailsState>(
      buildWhen: (previous, current) => current is! PackDetailsNoBuild,
      listener: (context, state) {
        if (state is PackDetailsLoading) {
          // TODO: Show loading modal/page
          // Navigator.of(context).push(LoadingPage.route(),);
        } else if (state is AssetTransferSuccess) {
          context.showSnackBar(
              message:
                  "Assets ${state.copy ? "copied" : "moved"} successfully");
        } else if (state is AnimatedAssetError) {
          context.showErrorSnackBar(
              message:
                  "Cannot mix animated and static stickers in the same pack ${state.errorPack.name}");
        } else if (state is PackAssetLimitExceededError) {
          context.showErrorSnackBar(
              message:
                  "Cannot add more than 30 stickers to a pack ${state.errorPack.name}");
        } else if (state is PackDetailsError) {
          context.showErrorSnackBar(message: "Something went wrong");
        }
      },
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
                context
                    .read<PackDetailsBloc>()
                    .add(value ? SelectAll() : DeselectAll());
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
            leading: state.selectMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        context.read<PackDetailsBloc>().add(ToggleSelectMode()),
                  )
                : null,
          ),
          body: Stack(
            children: [body, const SelectedAssetsOptionsSheet()],
          ),
        );
      },
    );
  }
}
