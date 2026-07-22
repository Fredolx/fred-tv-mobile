import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_tv/error.dart';
import 'package:url_launcher/url_launcher.dart';

const paypalUrl = "https://www.paypal.com/paypalme/fredolx";
const githubSponsorsUrl = "https://github.com/sponsors/Fredolx";
const btcAddress = "bc1q7v27u4mrxhtqzl97pcp4vl52npss760epsheu3";

const _sideBySideWidth = 600.0;
const _photoAsset = "assets/fred.jpg";
const _heading = "Support Fred TV";
const _signature = "Frédéric Lachapelle";

const _letter = '''
Hi! It's me, Fred, the developer of Fred TV. I made Fred TV with the sole and unique goal to bring back the notion of what software is truly meant to be: tools. Tools to serve us humans, not to control us or to exploit us. 

I want to dedicate myself to making open-source apps for a living. Help my dream become true, and be part of an open-source revolution to free us from the shackles of exploitative spyware ridden apps. Every donation helps towards this goal and funds future development.

From the bottom of my heart, thank you for using this app. If you enjoy Fred TV, please share it far and wide, and consider making a donation of any amount, even a dollar. Your trust, support and continued use of my applications are greatly appreciated.

IPTV is not the first or last domain we will change together. Expect more Fred apps in the future!

Thank you!''';

class DonateView extends StatelessWidget {
  final bool tvMode;
  const DonateView({super.key, this.tvMode = false});

  Future<void> openLink(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  Future<void> copyBtcAddress() async {
    await Clipboard.setData(const ClipboardData(text: btcAddress));
    Error.showMessage("Bitcoin address copied");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_heading)),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: tvMode ? buildTvLayout(context) : buildMobileLayout(context),
          ),
        ),
      ),
    );
  }

  Widget buildTvLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildPhoto(context, 200),
              ),
              const SizedBox(width: 40),
              Expanded(child: buildTextPanel(context)),
            ],
          ),
          const SizedBox(height: 40),
          buildQrRow(context),
        ],
      ),
    );
  }

  Widget buildTextPanel(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Builder(
        builder: (context) =>
            buildTextCard(context, focused: Focus.of(context).hasFocus),
      ),
    );
  }

  Widget buildTextCard(BuildContext context, {bool focused = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border.all(
          color: focused
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: buildText(context),
    );
  }

  Widget buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (constraints.maxWidth >= _sideBySideWidth)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: buildPhoto(context, 180),
                  ),
                  const SizedBox(width: 32),
                  Expanded(child: buildTextCard(context)),
                ],
              )
            else ...[
              Center(child: buildPhoto(context, 150)),
              const SizedBox(height: 24),
              buildTextCard(context),
            ],
            const SizedBox(height: 32),
            buildMobileActions(),
          ],
        ),
      ),
    );
  }

  Widget buildPhoto(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          _photoAsset,
          fit: BoxFit.cover,
          cacheWidth: (size * 3).round(),
        ),
      ),
    );
  }

  Widget buildText(BuildContext context) {
    final bodySize = tvMode
        ? (MediaQuery.sizeOf(context).height * 0.021).clamp(14.0, 24.0)
        : 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_letter, style: TextStyle(fontSize: bodySize, height: 1.5)),
        const SizedBox(height: 8),
        Text(
          _signature,
          style: TextStyle(
            fontSize: bodySize + 1,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget buildQrRow(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).height * 0.24).clamp(120.0, 280.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QrCard(label: "PayPal", asset: "assets/paypal.png", size: size),
        _QrCard(
          label: "GitHub Sponsors",
          asset: "assets/github.png",
          size: size,
        ),
        _QrCard(label: "Bitcoin", asset: "assets/btc.png", size: size),
      ],
    );
  }

  Widget buildMobileActions() {
    const style = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
      textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
    );
    final buttons = [
      FilledButton.icon(
        onPressed: () => openLink(paypalUrl),
        icon: const Icon(Icons.favorite),
        style: style,
        label: const Text("Donate with PayPal"),
      ),
      FilledButton.tonalIcon(
        onPressed: () => openLink(githubSponsorsUrl),
        icon: const Icon(Icons.code),
        style: style,
        label: const Text("GitHub Sponsors"),
      ),
      OutlinedButton.icon(
        onPressed: copyBtcAddress,
        icon: const Icon(Icons.copy),
        style: style,
        label: const Text("Copy Bitcoin address"),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: buttons,
    );
  }
}

class _QrCard extends StatelessWidget {
  final String label;
  final String asset;
  final double size;
  const _QrCard({required this.label, required this.asset, required this.size});

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final focused = Focus.of(context).hasFocus;
          final highlight = Theme.of(context).colorScheme.primary;
          return AnimatedScale(
            scale: focused ? 1.08 : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: focused ? highlight : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: Image.asset(
                      asset,
                      width: size,
                      height: size,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: (size * 0.11).clamp(15.0, 24.0),
                      letterSpacing: 0.5,
                      fontWeight: focused ? FontWeight.bold : FontWeight.normal,
                      color: focused ? highlight : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
