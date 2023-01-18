import 'package:flutter/material.dart';

class PlusAccordion extends StatefulWidget {
  const PlusAccordion({
    Key? key,
    required this.child,
    required this.header,
    this.onChanged,
    this.isExpandable = true,
  }) : super(key: key);
  final Widget child;
  final Widget header;
  final bool isExpandable;
  final Function(bool)? onChanged;
  @override
  State<PlusAccordion> createState() => _PlusAccordionState();
}

class _PlusAccordionState extends State<PlusAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    _isExpanded = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (panelIndex, isExpanded) {
          if (!widget.isExpandable) return;
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(_isExpanded);
          }
        },
        elevation: 0,
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            headerBuilder: (context, isExpanded) {
              return widget.header;
            },
            canTapOnHeader: true,
            body: widget.child,
          ),
        ],
      ),
    );
  }
}
