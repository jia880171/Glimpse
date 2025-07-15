import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glimpse/widgets/timeline_group/timeline_group.dart';

import '../../config.dart' as config;



class HorizontalDateTimeline extends StatefulWidget {
  final int modeType;
  final Size size;
  final DateTime selectedDate;
  final Map<DateTime, int> photosCountPerDay;

  const HorizontalDateTimeline({
    super.key,
    required this.size,
    required this.selectedDate,
    required this.photosCountPerDay,
    required this.modeType,
  });

  @override
  State<HorizontalDateTimeline> createState() => _HorizontalDateTimelineState();
}

class _HorizontalDateTimelineState extends State<HorizontalDateTimeline>
    with SingleTickerProviderStateMixin {
  bool _isAnimationReady = false;
  final int startYear = 2000;
  final int endYear = 2025;

  late AnimationController _controller;
  late Animation<double> _animation;
  double _selectedX = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 666));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedX();
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalDateTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(widget.selectedDate, oldWidget.selectedDate)) {
      _updateSelectedX();
    }
  }

  void _updateSelectedX() {
    final daysInMonth = DateUtils.getDaysInMonth(
        widget.selectedDate.year, widget.selectedDate.month);

    // Target may be a date, month or year
    int indexOfTarget = getTargetIndex();
    if (widget.modeType == modeYear) {
      indexOfTarget = widget.selectedDate.year - startYear + 1;
    }

    int numberOfItems = getNumberOfItems(daysInMonth);
    final spacing = calculateSpacing(numberOfItems);

    final newX = spacing * (indexOfTarget - 0.5);

    _animation =
        Tween<double>(begin: _selectedX, end: newX).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ))
          ..addListener(() {
            setState(() {});
          });

    _controller.forward(from: 0);
    _selectedX = newX;
    _isAnimationReady = true;
  }

  int getTargetIndex() {
    switch (widget.modeType) {
      case modeYear:
        return widget.selectedDate.year;
      case modeMonth:
        return widget.selectedDate.month;
      default:
        return widget.selectedDate.day;
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayBarHeight = widget.size.height * 0.5;
    final redBarHeight = widget.size.height * 0.9;
    final dayBarGapHeight = widget.size.height * 0.1;

    final daysInMonth = DateUtils.getDaysInMonth(
        widget.selectedDate.year, widget.selectedDate.month);
    late int numberOfItems = getNumberOfItems(daysInMonth);
    final spacing = calculateSpacing(numberOfItems);

    return Container(
      // color: Colors.green,
      color: config.timeLine,
      width: widget.size.width,
      height: widget.size.height,
      child: Stack(
        children: [
          Row(
            children: [
              for (int i = 0; i < numberOfItems; i++)
                Center(
                  child: Container(
                    width: spacing,
                    child: Column(
                      children: [
                        Container(
                          width: _hasPhotosOnIndex(i) ? 2 : 0.6,
                          height: dayBarHeight,
                          color: _hasPhotosOnIndex(i)
                              ? Colors.black.withOpacity(0.66)
                              : Colors.grey,
                        ),
                        SizedBox(height: dayBarGapHeight),
                        SizedBox(
                            height: dayBarHeight - dayBarGapHeight,
                            child: Text(
                              _getLabelForIndex(i),
                              style: TextStyle(
                                  fontSize: math.min(
                                      spacing / 2, dayBarGapHeight * 2)),
                            )

                            // style: TextStyle(fontSize: spacing / 2),
                            ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // red selected line
          if (_isAnimationReady)
            Positioned(
              left: _animation.value,
              bottom: 0,
              child: Container(
                width: 1.5,
                height: redBarHeight,
                color: config.timelinePointerRed,
              ),
            ),
        ],
      ),
    );
  }

  String _getLabelForIndex(int index) {
    switch (widget.modeType) {
      case modeYear:
        return (startYear + index).toString().substring(2);
      case modeMonth:
        return (index + 1).toString();
      default:
        return (index + 1).toString();
    }
  }

  double calculateSpacing(int daysInMonth) {
    switch (widget.modeType) {
      case modeYear:
        final yearCount = endYear - startYear + 1;
        return widget.size.width / yearCount;
      case modeMonth:
        return widget.size.width / 12;
      default:
        return widget.size.width / daysInMonth;
    }
  }

  int getNumberOfItems(int daysInMonth) {
    switch (widget.modeType) {
      case modeYear:
        return endYear - startYear + 1;
      case modeMonth:
        return 12;
      default:
        return daysInMonth;
    }
  }

  bool _hasPhotosOnIndex(int index) {
    switch (widget.modeType) {
      case modeYear:
        final year = startYear + index;
        for (final date in widget.photosCountPerDay.keys) {
          if (date.year == year) return true;
        }
        break;
      case modeMonth:
        final month = index + 1;
        final y = widget.selectedDate.year;
        for (final date in widget.photosCountPerDay.keys) {
          if (date.year == y && date.month == month) return true;
        }
        break;
      case modeDate:
      default:
        final day = index + 1;
        final y = widget.selectedDate.year;
        final m = widget.selectedDate.month;
        for (final date in widget.photosCountPerDay.keys) {
          if (date.year == y && date.month == m && date.day == day) return true;
        }
        break;
    }
    return false;
  }
}
