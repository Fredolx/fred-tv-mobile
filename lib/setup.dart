import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:open_tv/home.dart';
import 'package:open_tv/models/filters.dart';
import 'package:open_tv/models/home_manager.dart';
import 'package:open_tv/models/source_type.dart';
import 'package:open_tv/models/steps.dart';
import 'package:open_tv/models/view_type.dart';

class Setup extends StatefulWidget {
  final bool showAppBar;
  const Setup({super.key, this.showAppBar = false});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Steps step = Steps.welcome;
  SourceType selectedSourceType = SourceType.xtream;
  bool isForward = true;
  bool formValid = false;
  String? name;
  String? url;
  String? username;
  String? password;
  final FocusNode _firstFieldFocus = FocusNode();
  final formPages = {Steps.name, Steps.url, Steps.username, Steps.password};
  final _formKeys = {
    Steps.name: GlobalKey<FormBuilderState>(),
    Steps.url: GlobalKey<FormBuilderState>(),
    Steps.username: GlobalKey<FormBuilderState>(),
    Steps.password: GlobalKey<FormBuilderState>(),
  };
  final formValues = {
    Steps.name: "",
    Steps.url: "",
    Steps.username: "",
    Steps.password: ""
  };

  void finish() {
    setState(() {
      step = Steps.finish;
    });
  }

  @override
  void dispose() {
    _firstFieldFocus.dispose();
    super.dispose();
  }

  Future<bool> selectFile() async {
    var path = (await FilePicker.platform.pickFiles())?.files.single.path;
    if (path == null) return false;
    return true;
  }

  void prevStep() {
    isForward = false;
    if (formPages.contains(step)) {
      formValues[step] =
          _formKeys[step]?.currentState?.fields[step.name]?.value;
    }
    setState(() {
      step = Steps.values[step.index - 1];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        formValid = _formKeys[step]?.currentState?.isValid == true;
      });
    });
  }

  Future<void> handleNext() async {
    isForward = true;
    if (formPages.contains(step)) {
      formValues[step] =
          _formKeys[step]?.currentState?.fields[step.name]?.value;
    }
    if (step == Steps.sourceType && selectedSourceType == SourceType.m3u) {
      if (!await selectFile()) return;
      finish();
    } else if ((selectedSourceType == SourceType.m3uUrl && step == Steps.url) ||
        step == Steps.password) {
      finish();
    } else if (step == Steps.finish) {
      navigateToHome();
    } else {
      setState(() {
        step = Steps.values[step.index + 1];
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          formValid = _formKeys[step]?.currentState?.isValid == true;
        });
      });
    }
  }

  void navigateToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => Home(
                home: HomeManager(filters: Filters(viewType: ViewType.all)))),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: (step.index + 1) / Steps.values.length,
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[850],
                      minHeight: 6,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 400),
                  reverse: !isForward,
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) {
                    return SharedAxisTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  child: currentPage),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity:
                        step != Steps.welcome && step != Steps.finish ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: step == Steps.welcome || step == Steps.finish,
                      child: FilledButton.tonal(
                        onPressed: prevStep,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child:
                            const Text("Back", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: !formPages.contains(step) || formValid
                        ? handleNext
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: Text(
                      step == Steps.sourceType &&
                              selectedSourceType == SourceType.m3u
                          ? "Select file"
                          : step == Steps.finish
                              ? "Finish"
                              : "Next",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get currentPage {
    switch (step) {
      case Steps.welcome:
        return getPage(
            "Welcome to Fred TV", "Let's set up your first source", null);
      case Steps.sourceType:
        return getPage(
          "What is your provider type?",
          null,
          List.generate(SourceType.values.length, (i) {
            return Card(
              color: selectedSourceType.index == i
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              child: ListTile(
                title: Text((SourceType.values[i]).label),
                onTap: () {
                  setState(() {
                    selectedSourceType = SourceType.values[i];
                  });
                },
              ),
            );
          }),
        );
      case Steps.name:
        return getPage("What should we name this source?", null, [
          FormBuilder(
              onChanged: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    formValid =
                        _formKeys[Steps.name]!.currentState?.isValid == true;
                  });
                });
              },
              initialValue: {Steps.name.name: formValues[Steps.name]},
              key: _formKeys[Steps.name],
              child: FormBuilderTextField(
                autocorrect: false,
                focusNode: _firstFieldFocus,
                decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline)),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.minLength(1),
                name: 'name',
              )),
        ]);
      case Steps.url:
        return getPage("What is your provider's URL?", null, [
          FormBuilder(
            onChanged: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  formValid =
                      _formKeys[Steps.url]!.currentState?.isValid == true;
                });
              });
            },
            initialValue: {Steps.url.name: formValues[Steps.url]},
            key: _formKeys[Steps.url],
            child: FormBuilderTextField(
              autocorrect: false,
              focusNode: _firstFieldFocus,
              decoration: InputDecoration(
                  labelText: "URL",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link)),
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormBuilderValidators.minLength(1),
              name: 'url',
            ),
          )
        ]);
      case Steps.username:
        return getPage("What is your username?", null, [
          FormBuilder(
              onChanged: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    formValid =
                        _formKeys[Steps.username]!.currentState?.isValid ==
                            true;
                  });
                });
              },
              initialValue: {Steps.username.name: formValues[Steps.username]},
              key: _formKeys[Steps.username],
              child: FormBuilderTextField(
                autocorrect: false,
                focusNode: _firstFieldFocus,
                decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.minLength(1),
                name: 'username',
              ))
        ]);
      case Steps.password:
        return getPage("What is your password?", null, [
          FormBuilder(
            initialValue: {Steps.password.name: formValues[Steps.password]},
            onChanged: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  formValid =
                      _formKeys[Steps.password]!.currentState?.isValid == true;
                });
              });
            },
            key: _formKeys[Steps.password],
            child: FormBuilderTextField(
              autocorrect: false,
              focusNode: _firstFieldFocus,
              decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password)),
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormBuilderValidators.minLength(1),
              name: 'password',
            ),
          )
        ]);
      case Steps.finish:
        return getPage("Done!", "You're all set 🎉", null);
    }
  }

  Widget getPage(
      final String title, final String? subtitle, final List<Widget>? content) {
    return Center(
      key: ValueKey(title),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[
              const SizedBox(height: 24),
              ...content,
            ],
          ],
        ),
      ),
    );
  }
}
