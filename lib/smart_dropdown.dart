library smart_dropdown;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SmartDropDown<T> extends StatefulWidget {
  final List<SmartDropdownMenuItem> items;
  final Function onChanged;
  final String hintText;
  final double borderRadius;
  final double maxListHeight;
  final double borderWidth;
  final Color borderColor;
  final Color expandedColor;
  final int defaultSelectedIndex;
  final bool enabled;
  final Key key;

  SmartDropDown(
      {this.items,
      this.onChanged,
      this.hintText = "",
      this.borderRadius = 0,
      this.borderWidth = 1,
      this.borderColor = Colors.black,
      this.expandedColor = Colors.black,
      this.maxListHeight = 100,
      this.defaultSelectedIndex = -1,
      this.key,
      this.enabled = true})
      : super(key: key);

  @override
  _SmartDropDownState createState() => _SmartDropDownState();
}

class _SmartDropDownState extends State<SmartDropDown>
    with WidgetsBindingObserver {
  bool _isOpen = false, _isAnyItemSelected = false, _isReverse = false;
  OverlayEntry _overlayEntry;
  RenderBox _renderBox;
  Widget _itemSelected = null;
  Offset dropDownOffset;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          dropDownOffset = getOffset();
        });
      }
      if (widget.defaultSelectedIndex > -1) {
        // if user wants some default value to display
        if (widget.defaultSelectedIndex < widget.items.length) {
          // check if index is within range
          if (mounted) {
            setState(() {
              _isAnyItemSelected = true;
              _itemSelected = widget.items[widget.defaultSelectedIndex];
              widget.onChanged(widget.items[widget.defaultSelectedIndex].value);
            });
          }
        }
      }
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _addOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }

    this._overlayEntry = this._createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
  }

  void _removeOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
      this._overlayEntry.remove();
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    _renderBox = context.findRenderObject();

    var size = _renderBox.size;

    if (dropDownOffset == null) {
      dropDownOffset = Offset(0, _renderBox.size.height);
    }
    if (dropDownOffset != null) {
      dropDownOffset = getOffset();
    }

    return OverlayEntry(
        maintainState: false,
        builder: (context) => Align(
              alignment: Alignment.center,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: dropDownOffset,
                child: Container(
                  height: widget.maxListHeight,
                  width: size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: _isReverse
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: widget.maxListHeight,
                            maxWidth: size.width),
                        decoration: _getListDecoration(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(widget.borderRadius),
                          ),
                          child: Material(
                            elevation: 0,
                            shadowColor: Colors.grey,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: widget.items
                                  .map((item) => GestureDetector(
                                        child: item.child,
                                        onTap: () {
                                          if (mounted) {
                                            setState(() {
                                              _isAnyItemSelected = true;
                                              _itemSelected = item.child;
                                              _removeOverlay();
                                              if (widget.onChanged != null)
                                                widget.onChanged(item.value);
                                            });
                                          }
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Offset getOffset() {
    RenderBox renderBox = context.findRenderObject();
    double y = renderBox.localToGlobal(Offset.zero).dy;
    double spaceAvailable = _getAvailableSpace(y + renderBox.size.height);
    if (spaceAvailable > widget.maxListHeight) {
      _isReverse = false;
      return Offset(0, renderBox.size.height);
    } else {
      _isReverse = true;
      return Offset(
          0,
          renderBox.size.height -
              (widget.maxListHeight + renderBox.size.height));
    }
  }

  double _getAvailableSpace(double offsetY) {
    double safePaddingTop = MediaQuery.of(context).padding.top;
    double safePaddingBottom = MediaQuery.of(context).padding.bottom;

    double screenHeight =
        MediaQuery.of(context).size.height - safePaddingBottom - safePaddingTop;

    return screenHeight - offsetY;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          ThemeData(textTheme: TextTheme(body1: TextStyle(color: Colors.grey))),
      child: CompositedTransformTarget(
        link: this._layerLink,
        child: GestureDetector(
          onTap: widget.enabled
              ? () {
                  // to open /close popup when widget is enabled
                  _isOpen ? _removeOverlay() : _addOverlay();
                }
              : null,
          child: Container(
            decoration: _getDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: _isAnyItemSelected
                      ? _itemSelected
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 4.0), // change it here
                          child: Text(
                            widget.hintText,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                ),
                Flexible(
                  flex: 1,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: widget.expandedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BorderSide _getNormalBorderSide() {
    return BorderSide(
        width: widget.borderWidth,
        style: BorderStyle.solid,
        color: widget.expandedColor);
  }

  Decoration _getDecoration() {
    if (_isOpen && !_isReverse) {
      return BoxDecoration(
          border: Border.all(
              width: widget.borderWidth,
              style: BorderStyle.solid,
              color: widget.expandedColor),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (_isOpen && _isReverse) {
      return BoxDecoration(
          border: Border.all(
              width: widget.borderWidth,
              style: BorderStyle.solid,
              color: widget.expandedColor),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (!_isOpen) {
      return BoxDecoration(
          border: Border.all(
              width: widget.borderWidth,
              style: BorderStyle.solid,
              color: widget.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)));
    }
  }

  Decoration _getListDecoration() {
    if (_isOpen && !_isReverse) {
      return BoxDecoration(
          border: Border(
            left: _getNormalBorderSide(),
            right: _getNormalBorderSide(),
            bottom: _getNormalBorderSide(),
            top: _getNormalBorderSide(),
          ),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (_isOpen && _isReverse) {
      return BoxDecoration(
          border: Border.all(
              width: widget.borderWidth,
              style: BorderStyle.solid,
              color: widget.expandedColor),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (!_isOpen) {
      return BoxDecoration(
          border: Border.all(
              width: widget.borderWidth,
              style: BorderStyle.solid,
              color: widget.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)));
    }
  }
}

class SmartDropdownMenuItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  SmartDropdownMenuItem({@required this.value, @required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
