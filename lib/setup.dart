import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:open_tv/backend/sql.dart';
import 'package:open_tv/backend/utils.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/loading.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:open_tv/error.dart';

class Setup extends StatefulWidget {
  final bool showAppBar;
  const Setup({super.key, this.showAppBar = false});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  bool formValid = false;
  Set<String> existingSourceNames = {};

  showXtreamCorrectionModal() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Is this the right URL?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Proceed anyway")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Correct URL automatically"))
              ],
              content: const Text(
                  "It seems your url is not pointing to an Xtream API server, Open TV can correct the URL automatically for you"),
            ));
  }

  Future<String> fixUrl(String url) async {
    var uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      uri = Uri.parse("http://$uri");
    }
    if (uri.path == "/" || uri.path.isEmpty) {
      if (await showXtreamCorrectionModal()) {
        uri = uri.resolve("player_api.php");
      }
    }
    return uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(title: const Text("Adding a new source"))
            : null,
        body: Loading(
            child: SafeArea(
                child: FormBuilder(
                    onChanged: () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        setState(() {
                          formValid = _formKey.currentState?.isValid == true;
                        });
                      });
                    },
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(
                            height: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 100
                                : 10),
                        ToggleButtons(
                          isSelected: List.generate(
                              3, (index) => index == _selectedIndex),
                          onPressed: (index) {
                            setState(() {
                              _selectedIndex = index;
                            });
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              setState(() {
                                formValid =
                                    _formKey.currentState?.isValid == true;
                              });
                            });
                          },
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Xtream'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('M3U URL'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('M3U File'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1),
                          child: FormBuilderTextField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              (value) {
                                var trimmed = value?.trim();
                                if (trimmed == null || trimmed.isEmpty) {
                                  return null;
                                }
                                if (existingSourceNames.contains(trimmed)) {
                                  return "Name already exists";
                                }
                                return null;
                              }
                            ]),
                            decoration: const InputDecoration(
                              labelText: 'Name', // Label inside the input
                              prefixIcon: Icon(Icons
                                  .edit), // Icon inside the input (left side)
                              border: OutlineInputBorder(),
                            ),
                            name: 'name',
                          ),
                        ),
                        if (_selectedIndex == SourceType.xtream.index ||
                            _selectedIndex == SourceType.m3uUrl.index)
                          const SizedBox(height: 15),
                        if (_selectedIndex == SourceType.xtream.index ||
                            _selectedIndex == SourceType.m3uUrl.index)
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.1),
                              child: FormBuilderTextField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: FormBuilderValidators.compose(
                                    [FormBuilderValidators.required()]),
                                decoration: const InputDecoration(
                                  labelText: 'URL', // Label inside the input
                                  prefixIcon: Icon(Icons
                                      .link), // Icon inside the input (left side)
                                  border: OutlineInputBorder(),
                                ),
                                name: 'url',
                              )),
                        if (_selectedIndex == SourceType.xtream.index)
                          const SizedBox(height: 15),
                        if (_selectedIndex == SourceType.xtream.index)
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.1),
                              child: FormBuilderTextField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: FormBuilderValidators.compose(
                                    [FormBuilderValidators.required()]),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Username', // Label inside the input
                                  prefixIcon: Icon(Icons
                                      .account_circle), // Icon inside the input (left side)
                                  border: OutlineInputBorder(),
                                ),
                                name: 'username',
                              )),
                        if (_selectedIndex == SourceType.xtream.index)
                          const SizedBox(height: 15),
                        if (_selectedIndex == SourceType.xtream.index)
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.1),
                              child: FormBuilderTextField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: FormBuilderValidators.compose(
                                    [FormBuilderValidators.required()]),
                                decoration: const InputDecoration(
                                  labelText:
                                      'Password', // Label inside the input
                                  prefixIcon: Icon(Icons
                                      .password), // Icon inside the input (left side)
                                  border: OutlineInputBorder(),
                                ),
                                name: 'password',
                              )),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: formValid
                                ? Colors.blue
                                : Colors.grey, // Disabled color
                            foregroundColor: Colors.white, // Text color
                          ),
                          onPressed: () async {
                            final sourceName = (_formKey.currentState
                                    ?.instantValue["name"] as String)
                                .trim();
                            if (await Sql.sourceNameExists(sourceName)) {
                              existingSourceNames.add(sourceName);
                            }
                            if (_formKey.currentState?.saveAndValidate() ==
                                false) {
                              return;
                            }
                            final sourceType =
                                SourceType.values[_selectedIndex];
                            var url = sourceType == SourceType.m3u
                                ? (await FilePicker.platform.pickFiles())
                                    ?.files
                                    .single
                                    .path
                                : (_formKey.currentState?.value["url"]
                                    as String);
                            if (sourceType == SourceType.m3u && url == null) {
                              return;
                            }
                            if (sourceType == SourceType.xtream) {
                              url = await fixUrl(url!);
                            }
                            final result = await Error.tryAsync(() async {
                              await Utils.processSource(
                                Source(
                                  name: sourceName,
                                  sourceType: sourceType,
                                  url: url,
                                  username: sourceType == SourceType.xtream
                                      ? (_formKey.currentState
                                              ?.value["username"] as String)
                                          .trim()
                                      : null,
                                  password: sourceType == SourceType.xtream
                                      ? (_formKey.currentState
                                              ?.value["password"] as String)
                                          .trim()
                                      : null,
                                ),
                              );
                            }, context, "Successfully added source");
                            if (result.success) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()));
                            }
                          },
                          child: const Text("Submit"),
                        )
                      ]),
                    )))));
  }
}
