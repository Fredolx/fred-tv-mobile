import 'package:flutter/material.dart';
import 'package:open_tv/models/channel.dart';

class ChannelTile extends StatefulWidget {
  final Channel channel;
  final VoidCallback onSelect;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.onSelect,
  });

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (isFocused) {
        setState(() {}); // Update UI on focus change
      },
      child: InkWell(
        focusColor: Colors.transparent, // Make the focus effect transparent
        onTap: widget.onSelect,
        child: Card(
          elevation: _focusNode.hasFocus ? 8.0 : 4.0, // Highlight when focused
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: _focusNode.hasFocus ? Colors.blue.shade100 : Colors.white,
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
      ),
    );
  }
}
