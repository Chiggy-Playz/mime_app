import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_app/core/extensions/build_context_extensions.dart';
import 'package:mime_app/new_pack/bloc/new_pack_bloc.dart';

class NewPackWidget extends StatefulWidget {
  const NewPackWidget({super.key});

  @override
  State<NewPackWidget> createState() => _NewPackWidgetState();
}

class _NewPackWidgetState extends State<NewPackWidget> {
  final _formKey = GlobalKey<FormState>();
  String name = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewPackBloc, NewPackState>(
      listener: (context, state) {
        if (state is NewPackLoading) return;
        setState(() {
          loading = false;
        });
        if (state is NewPackSuccess) {
          Navigator.of(context).pop();
        } else if (state is PackNameConflict) {
          context.showErrorSnackBar(message: "Pack with name already exists.");
        } else if (state is DatabaseError) {
          context.showErrorSnackBar(
              message: "An unknown database error occured.");
        } else if (state is UnknownError) {
          context.showErrorSnackBar(message: "An unknown error occured.");
        }
      },
      builder: (context, state) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("New pack", style: context.headlineMedium),
                      FilledButton(
                        onPressed: savePressed,
                        child: loading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  color: context.onPrimary,
                                ),
                              )
                            : const Text("Save"),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    enabled: !loading,
                    decoration: const InputDecoration(
                      hintText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      if (value != null) {
                        name = value;
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                if (state is PackNameConflict && !loading)
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.error,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Pack with name already exists.",
                          style: context.bodyMedium!.copyWith(
                            color: context.onError,
                          ),
                        ),
                      ))
                else if (state is DatabaseError && !loading)
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.error,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "An unknown database error occured.",
                          style: context.bodyMedium!.copyWith(
                            color: context.onError,
                          ),
                        ),
                      ))
                else if (state is UnknownError && !loading)
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.error,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "An unknown error occured.",
                          style: context.bodyMedium!.copyWith(
                            color: context.onError,
                          ),
                        ),
                      ))
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> savePressed() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      loading = true;
    });
    BlocProvider.of<NewPackBloc>(context).add(PackSaved(name, ""));
  }
}
