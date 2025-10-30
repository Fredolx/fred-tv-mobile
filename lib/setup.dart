import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class Setup extends StatefulWidget {
  final bool showAppBar;
  const Setup({super.key, this.showAppBar = false});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  int step = 0;
  int selected = 0;
  bool isForward = true;
  bool formValid = false;
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> options = ["Xtream", "M3U Url", "M3U File"];
  final formPages = {2, 3, 4};

  void nextStep() {
    isForward = true;
    setState(() {
      step++;
      formValid = false;
    });
  }

  void prevStep() {
    isForward = false;

    if (step > 0) setState(() => step--);
  }

  void handleNext() {
    nextStep();
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
                  end: (step + 1) / 7,
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
                  child: FormBuilder(
                      onChanged: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            formValid = _formKey.currentState?.isValid == true;
                          });
                        });
                      },
                      key: _formKey,
                      child: currentPage)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    opacity: step > 0 ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: IgnorePointer(
                      ignoring: step == 0,
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
                      step == 6 ? "Finish" : "Next",
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
      case 0:
        return getPage(
            "Welcome to Fred TV", "Let's set up your first source", null);
      case 1:
        return getPage(
          "What is your provider type?",
          null,
          List.generate(options.length, (i) {
            return Card(
              color: selected == i
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              child: ListTile(
                title: Text(options[i]),
                onTap: () {
                  setState(() {
                    selected = i;
                  });
                },
              ),
            );
          }),
        );
      case 2:
        return getPage("What should we name this source?", null, [
          FormBuilderTextField(
            autocorrect: false,
            decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline)),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.minLength(1),
            name: 'name',
          ),
        ]);
      case 3:
        return getPage("What is your provider's URL?", null, [
          FormBuilderTextField(
            autocorrect: false,
            decoration: InputDecoration(
                labelText: "URL",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link)),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.minLength(1),
            name: 'url',
          ),
        ]);
      case 4:
        return getPage("What is your username?", null, [
          FormBuilderTextField(
            autocorrect: false,
            decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person)),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.minLength(1),
            name: 'username',
          )
        ]);
      case 5:
        return getPage("What is your password?", null, [
          FormBuilderTextField(
            autocorrect: false,
            decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.password)),
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.minLength(1),
            name: 'password',
          ),
        ]);
      case 6:
        return getPage("Done!", "You're all set 🎉", null);
      default:
        return const SizedBox();
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
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 20),
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
