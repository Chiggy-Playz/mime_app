import 'package:assets_repository/assets_repository.dart';
import 'package:flutter/material.dart';
import 'package:mime_app/detailed_view/presentation/widgets/sticker_pack_widget.dart';

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
    );
  }
}
