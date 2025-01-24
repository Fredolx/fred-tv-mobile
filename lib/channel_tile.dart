import 'package:flutter/material.dart';
import 'package:open_tv/models/channel.dart';

class ChannelTile extends StatefulWidget {
  final Channel channel;

  const ChannelTile({
    super.key,
    required this.channel,
  });

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _focusNode.hasFocus ? 8.0 : 4.0, // Highlight when focused
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: _focusNode.hasFocus ? Colors.blue.shade100 : Colors.white,
      child: InkWell(
        focusNode: _focusNode,
        onTap: () => print("Selected ${widget.channel.name}"),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.channel.name!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _focusNode.hasFocus ? Colors.blue : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${widget.channel.id}',
                style: TextStyle(
                  color: _focusNode.hasFocus ? Colors.blue : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
