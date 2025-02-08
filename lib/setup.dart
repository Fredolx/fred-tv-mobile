import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:open_tv/backend/m3u.dart';
import 'package:open_tv/models/source.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:open_tv/error.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  bool formValid = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FormBuilder(
      onChanged: () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            formValid = _formKey.currentState?.isValid == true;
          });
        });
      },
      key: _formKey,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToggleButtons(
              isSelected: List.generate(3, (index) => index == _selectedIndex),
              onPressed: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  setState(() {
                    formValid = _formKey.currentState?.isValid == true;
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
                  horizontal: MediaQuery.of(context).size.width * 0.1),
              child: FormBuilderTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required()]),
                decoration: const InputDecoration(
                  labelText: 'Name', // Label inside the input
                  prefixIcon:
                      Icon(Icons.edit), // Icon inside the input (left side)
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
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()]),
                    decoration: const InputDecoration(
                      labelText: 'URL', // Label inside the input
                      prefixIcon:
                          Icon(Icons.link), // Icon inside the input (left side)
                      border: OutlineInputBorder(),
                    ),
                    name: 'url',
                  )),
            if (_selectedIndex == SourceType.xtream.index)
              const SizedBox(height: 15),
            if (_selectedIndex == SourceType.xtream.index)
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()]),
                    decoration: const InputDecoration(
                      labelText: 'Username', // Label inside the input
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
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: FormBuilderTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormBuilderValidators.compose(
                        [FormBuilderValidators.required()]),
                    decoration: const InputDecoration(
                      labelText: 'Password', // Label inside the input
                      prefixIcon: Icon(
                          Icons.password), // Icon inside the input (left side)
                      border: OutlineInputBorder(),
                    ),
                    name: 'password',
                  )),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    formValid ? Colors.blue : Colors.grey, // Disabled color
                foregroundColor: Colors.white, // Text color
              ),
              onPressed: () async {
                _formKey.currentState?.saveAndValidate();
                var filePath =
                    (await FilePicker.platform.pickFiles())?.files.single.path;
                if (filePath != null) {
                  try {
                    await processM3U(Source(
                        name: _formKey.currentState?.value["name"],
                        sourceType: SourceType.m3u.index,
                        enabled: true,
                        url: filePath));
                  } catch (e) {
                    Error.handleError(context, e);
                  }
                }
              },
              child: const Text("Submit"),
            )
          ]),
    ));
  }
}
