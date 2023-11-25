import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/widgets/labeled_icon.dart';
import 'package:mime_app/detailed_view/bloc/pack_details_bloc.dart';
import 'package:mime_app/pack_selector/bloc/pack_selector_bloc.dart';
import 'package:mime_app/pack_selector/presentation/screens/pack_select_screen.dart';

class SelectedAssetsOptionsSheet extends StatefulWidget {
  const SelectedAssetsOptionsSheet({super.key});

  @override
  State<SelectedAssetsOptionsSheet> createState() =>
      _SelectedAssetsOptionsSheetState();
}

class _SelectedAssetsOptionsSheetState
    extends State<SelectedAssetsOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackDetailsBloc, PackDetailsState>(
      buildWhen: (previous, current) => current is! PackDetailsNoBuild,
      builder: (context, state) {
        return TweenAnimationBuilder(
          tween: Tween<double>(
            begin: 0.0,
            end: state.selectedAssets.isNotEmpty ? 0.15 : 0.0,
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
          builder: (context, value, child) {
            return DraggableScrollableSheet(
              minChildSize: 0.0,
              maxChildSize: 0.15,
              initialChildSize: value,
              builder: (context, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!state.pack.isUnassigned)
                            LabeledIcon(
                              iconData: Icons.copy,
                              label: "Copy to",
                              onTap: () async =>
                                  transferAssetsPressed(copy: true),
                            ),
                          LabeledIcon(
                            iconData: Icons.move_to_inbox,
                            label: "Move to",
                            onTap: () async =>
                                transferAssetsPressed(copy: false),
                          ),
                          LabeledIcon(
                            iconData: Icons.delete,
                            label: "Delete",
                            onTap: deleteAssetsPressed,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> transferAssetsPressed({required bool copy}) async {
    final assetsRepository = RepositoryProvider.of<AssetsRepository>(context);
    final packSelectorBloc = PackSelectorBloc(
      assetsRepository,
    );

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: packSelectorBloc,
          child: const PackSelectorScreen(),
        ),
      ),
    );
    if (!mounted) return;

    Set<Pack> selectedPacks = packSelectorBloc.selectedPacks;
    var packDetailsBloc = context.read<PackDetailsBloc>();
    var assets = packDetailsBloc.pack.assets
        .where((asset) => packDetailsBloc.selectedAssets.contains(asset.id))
        .toList();
    await packSelectorBloc.close();

    if (selectedPacks.isEmpty) return;

    packDetailsBloc.add(TransferAssets(selectedPacks.toList(), assets, copy));
  }

  Future<void> deleteAssetsPressed() async {
    var packDetailsBloc = context.read<PackDetailsBloc>();
    var assets = packDetailsBloc.pack.assets
        .where((asset) => packDetailsBloc.selectedAssets.contains(asset.id))
        .toList();

    packDetailsBloc.add(DeleteAssets(assets));
  }
}
