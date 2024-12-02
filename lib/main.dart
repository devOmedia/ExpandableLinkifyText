import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text("Expandable Linkify Text")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ExpandableLinkifyText(
          text:
              "This is a long text example with a link to https://flutter.dev "
              "and https://github.com. Expand to read more or collapse.",
          trimLines: 2,
          textStyle: TextStyle(fontSize: 16),
          linkStyle: TextStyle(color: Colors.blue),
        ),
      ),
    ),
  ));
}

class ExpandableLinkifyText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final String expandText;
  final String collapseText;

  const ExpandableLinkifyText({
    super.key,
    required this.text,
    this.trimLines = 2,
    this.textStyle,
    this.linkStyle,
    this.expandText = "Read more",
    this.collapseText = "Show less",
  });

  @override
  _ExpandableLinkifyTextState createState() => _ExpandableLinkifyTextState();
}

class _ExpandableLinkifyTextState extends State<ExpandableLinkifyText> {
  bool isExpanded = false;

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      try {
        await launchUrl(Uri.parse(link.url));
      } catch (e) {
        debugPrint("Error launching URL: $e");
        // Optionally handle the error, e.g., show a snackbar
      }
    } else {
      debugPrint("Could not launch ${link.url}");
      // Consider showing a message to the user indicating the URL is invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: textStyle);
        final textPainter = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isExpanded && isOverflowing)
              Linkify(
                text: _truncateText(widget.text, textPainter),
                style: textStyle,
                linkStyle: widget.linkStyle,
                onOpen: _onOpen,
              )
            else
              Linkify(
                text: widget.text,
                style: textStyle,
                linkStyle: widget.linkStyle,
                onOpen: _onOpen,
              ),
            if (isOverflowing)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? widget.collapseText : widget.expandText,
                  style: widget.textStyle!.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _truncateText(String text, TextPainter textPainter) {
    int endIndex = textPainter
        .getPositionForOffset(
          Offset(textPainter.width, textPainter.height),
        )
        .offset;
    return '${text.substring(0, endIndex)}...';
  }
}
