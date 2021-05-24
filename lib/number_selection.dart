import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// the concept of the widget inspired
/// from [Nikolay Kuchkarov](https://dribbble.com/shots/3368130-Stepper-Touch).
/// and thanks to Raouf Rahiche for starting this

class NumberSelection extends StatefulWidget {
  const NumberSelection(
      {Key? key,
      this.initialValue,
      this.onChanged,
      this.onOutOfConstraints,
      this.enableOnOutOfConstraintsAnimation = true,
      this.direction = Axis.horizontal,
      this.withSpring = true,
      this.maxValue = 100,
      this.minValue = -100,
      this.theme})
      : super(key: key);

  /// the orientation of the stepper its horizontal or vertical.
  final Axis direction;

  /// the initial value of the stepper
  final int? initialValue;

  /// called whenever the value of the stepper changed
  final ValueChanged<int>? onChanged;

  /// called when user try to change value to a value that is superior as
  /// [maxValue] or inferior as [minValue]
  ///
  /// this is useful to trigger an [HapticFeedBack] or other
  final Function? onOutOfConstraints;

  /// Enable the color and boomerang animation when user try to change value to
  /// a value that is superior as [maxValue] or inferior as [minValue]
  ///
  /// Defaults to [true]
  final bool enableOnOutOfConstraintsAnimation;

  /// if you want a springSimulation to happens the the user let go the stepper
  /// defaults to true
  final bool withSpring;

  /// minimum on the value it can be
  /// defaults is -100
  final int minValue;

  /// maximum of the value it can reach
  /// defaults is 100
  final int maxValue;

  /// Theme of the [NumberSelection] widget:
  ///
  ///
  /// -[draggableCircleColor] defaults to Theme.of(context).canvasColor
  ///
  /// -[numberColor] defaults to Theme.of(context).accentColor
  ///
  /// -[iconsColor] defaults to Theme.of(context).accentColor
  ///
  /// -[backgroundColor] defaults to Theme.of(context).primaryColor.withOpacity(0.7)
  ///
  /// -[outOfConstraintsColor]  defaults to Colors.red
  final NumberSelectionTheme? theme;

  @override
  _NumberSelectionState createState() => _NumberSelectionState();
}

class _NumberSelectionState extends State<NumberSelection>
    with TickerProviderStateMixin {
  late bool _isHorizontal = widget.direction == Axis.horizontal;
  late AnimationController _controller = AnimationController(
      vsync: this, lowerBound: -0.5, upperBound: 0.5, value: 0);
  late Animation _animation = _isHorizontal
      ? _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(1.5, 0.0))
              .animate(_controller)
      : _animation =
          Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, 1.5))
              .animate(_controller);
  late int _value = widget.initialValue ?? 0;
  late double _startAnimationPosX;
  late double _startAnimationPosY;

  late double _startAnimationOutOfConstraintsPosX;
  late double _startAnimationOutOfConstraintsPosY;

  late AnimationController _backgroundColorController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 350), value: 0)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _backgroundColorController.animateTo(0, curve: Curves.easeIn);
      }
    });
  final ColorTween _backgroundColorTween = ColorTween();
  late Animation<Color?> _backgroundColor = _backgroundColorController.drive(
      _backgroundColorTween.chain(CurveTween(curve: Curves.fastOutSlowIn)));

  late NumberSelectionTheme _theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundColorController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    _getTheme();
    _isHorizontal = widget.direction == Axis.horizontal;
    _backgroundColorTween
      ..begin = _theme.backgroundColor
      ..end = _theme.outOfConstraintsColor;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    _getTheme();
    _backgroundColorTween
      ..begin = _theme.backgroundColor
      ..end = _theme.outOfConstraintsColor;
    super.didChangeDependencies();
  }

  void _getTheme() {
    if (widget.theme != null)
      _theme = NumberSelectionTheme(
          draggableCircleColor: widget.theme!.draggableCircleColor ??
              Theme.of(context).canvasColor,
          numberColor: widget.theme!.numberColor ??
              Theme.of(context).colorScheme.secondary,
          iconsColor: widget.theme!.iconsColor ??
              Theme.of(context).colorScheme.secondary,
          backgroundColor: widget.theme!.backgroundColor ??
              Theme.of(context).primaryColor.withOpacity(0.7),
          outOfConstraintsColor:
              widget.theme!.outOfConstraintsColor ?? Colors.red);
    else
      _theme = NumberSelectionTheme(
        draggableCircleColor: Theme.of(context).canvasColor,
        numberColor: Theme.of(context).colorScheme.secondary,
        iconsColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        outOfConstraintsColor: Colors.red,
      );
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: _isHorizontal ? 280.0 : 120.0,
        height: _isHorizontal ? 120.0 : 280.0,
        child: AnimatedBuilder(
          animation: _backgroundColorController,
          builder: (BuildContext context, Widget? child) => Material(
            type: MaterialType.canvas,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(60.0),
            color: _backgroundColor.value,
            child: child,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: _isHorizontal ? 13 : 0,
                right: _isHorizontal ? null : 0,
                bottom: _isHorizontal ? 0 : 13,
                top: _isHorizontal ? 0 : null,
                child: IconButton(
                  icon: Icon(Icons.remove, size: 40, color: _theme.iconsColor),
                  onPressed: () =>
                      _changeValue(adding: false, fromButtons: true),
                ),
              ),
              Positioned(
                left: _isHorizontal ? null : 0,
                right: _isHorizontal ? 13 : 0,
                top: _isHorizontal ? 0 : 13,
                bottom: _isHorizontal ? 0 : null,
                child: IconButton(
                  icon: Icon(Icons.add, size: 40, color: _theme.iconsColor),
                  onPressed: () =>
                      _changeValue(adding: true, fromButtons: true),
                ),
              ),
              GestureDetector(
                onHorizontalDragStart: _onPanStart,
                onHorizontalDragUpdate: _onPanUpdate,
                onHorizontalDragEnd: _onPanEnd,
                child: SlideTransition(
                  position: _animation as Animation<Offset>,
                  child: Material(
                    color: _theme.draggableCircleColor,
                    shape: const CircleBorder(),
                    elevation: 5.0,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              child: child, scale: animation);
                        },
                        child: Text(
                          '$_value',
                          key: ValueKey<int>(_value),
                          style: TextStyle(
                              color: _theme.numberColor, fontSize: 56.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double offsetFromGlobalPos(Offset globalPosition) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset local = box.globalToLocal(globalPosition);
    _startAnimationPosX = ((local.dx * 0.75) / box.size.width) - 0.4;
    _startAnimationPosY = ((local.dy * 0.75) / box.size.height) - 0.4;

    _startAnimationOutOfConstraintsPosX =
        ((local.dx * 0.25) / box.size.width) - 0.4;
    _startAnimationOutOfConstraintsPosY =
        ((local.dy * 0.25) / box.size.height) - 0.4;

    if (_isHorizontal) {
      return ((local.dx * 0.75) / box.size.width) - 0.4;
    } else {
      return ((local.dy * 0.75) / box.size.height) - 0.4;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.value = offsetFromGlobalPos(details.globalPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _controller.stop();

    if (_controller.value <= -0.20) {
      _isHorizontal ? _changeValue(adding: false) : _changeValue(adding: true);
    } else if (_controller.value >= 0.20) {
      _isHorizontal ? _changeValue(adding: true) : _changeValue(adding: false);
    }
  }

  void _changeValue({required bool adding, bool fromButtons = false}) async {
    if (fromButtons) {
      _startAnimationPosX = _startAnimationPosY = adding ? 0.5 : -0.5;
      _startAnimationOutOfConstraintsPosX =
          _startAnimationOutOfConstraintsPosY = adding ? 0.25 : 0.25;
    }

    bool valueOutOfConstraints = false;
    if (adding && _value + 1 <= widget.maxValue)
      setState(() => _value++);
    else if (!adding && _value - 1 >= widget.minValue)
      setState(() => _value--);
    else
      valueOutOfConstraints = true;

    if (widget.withSpring) {
      final SpringDescription _kDefaultSpring =
          new SpringDescription.withDampingRatio(
        mass: valueOutOfConstraints && widget.enableOnOutOfConstraintsAnimation
            ? 0.4
            : 0.9,
        stiffness:
            valueOutOfConstraints && widget.enableOnOutOfConstraintsAnimation
                ? 1000
                : 250.0,
        ratio: 0.6,
      );
      if (_isHorizontal) {
        _controller.animateWith(SpringSimulation(
            _kDefaultSpring,
            valueOutOfConstraints && widget.enableOnOutOfConstraintsAnimation
                ? _startAnimationOutOfConstraintsPosX
                : _startAnimationPosX,
            0.0,
            0.0));
      } else {
        _controller.animateWith(SpringSimulation(
            _kDefaultSpring,
            valueOutOfConstraints && widget.enableOnOutOfConstraintsAnimation
                ? _startAnimationOutOfConstraintsPosY
                : _startAnimationPosY,
            0.0,
            0.0));
      }
    } else {
      _controller.animateTo(0.0,
          curve: Curves.bounceOut, duration: Duration(milliseconds: 500));
    }

    if (valueOutOfConstraints) {
      if (widget.onOutOfConstraints != null) widget.onOutOfConstraints!();
      if (widget.enableOnOutOfConstraintsAnimation)
        _backgroundColorController.forward();
    } else if (widget.onChanged != null) widget.onChanged!(_value);
  }
}

class NumberSelectionTheme {
  Color? draggableCircleColor;
  Color? numberColor;
  Color? iconsColor;
  Color? backgroundColor;
  Color? outOfConstraintsColor;

  NumberSelectionTheme(
      {this.draggableCircleColor,
      this.numberColor,
      this.iconsColor,
      this.backgroundColor,
      this.outOfConstraintsColor});
}
