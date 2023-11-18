import 'package:flutter/material.dart';
import 'package:mime_app/core/extensions/build_context_extensions.dart';

class NewPackWidget extends StatefulWidget {
  const NewPackWidget({super.key});

  @override
  State<NewPackWidget> createState() => _NewPackWidgetState();
}

class _NewPackWidgetState extends State<NewPackWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("New pack", style: context.headlineMedium),
              FilledButton(
                onPressed: savePressed,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Name",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {},
          ),
        )
      ],
    );
  }

  Future<void> savePressed() async {}
}
