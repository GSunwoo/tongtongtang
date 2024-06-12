import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthView extends StatefulWidget {
  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime? _firstSelectedDay;
  DateTime? _secondSelectedDay;
  List<DateTime> _selectedDays = [];
  Map<DateTime, List<String>> _events = {};
  Map<String, List<DateTime>> _eventDates = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('월간 일정'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        daysOfWeekVisible: true,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
        ),
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
          defaultDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.red),
          weekdayStyle: TextStyle(color: Colors.black),
        ),
        selectedDayPredicate: (day) {
          return _selectedDays.contains(day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            if (_firstSelectedDay == null || (_firstSelectedDay != null && _secondSelectedDay != null)) {
              _firstSelectedDay = selectedDay;
              _secondSelectedDay = null;
              _selectedDays = [selectedDay];
            } else if (_secondSelectedDay == null) {
              _secondSelectedDay = selectedDay;
              _selectedDays = _generateDateRange(_firstSelectedDay!, _secondSelectedDay!);
              _showActivityDialog();
            }
          });
        },
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, events) {
            return _buildSelectedDay(date);
          },
          markerBuilder: (context, date, events) {
            return _buildEventMarker(date);
          },
          todayBuilder: (context, date, _) {
            return _buildTodayMarker(date);
          },
          outsideBuilder: (context, date, _) {
            return SizedBox.shrink();
          },
          defaultBuilder: (context, date, _) {
            return _buildDefaultDay(date);
          },
        ),
      ),
    );
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    List<DateTime> days = [];
    DateTime current = start;

    if (start.isBefore(end)) {
      while (!current.isAfter(end)) {
        days.add(current);
        current = current.add(Duration(days: 1));
      }
    } else {
      while (!current.isBefore(end)) {
        days.add(current);
        current = current.subtract(Duration(days: 1));
      }
    }

    return days;
  }

  Widget _buildSelectedDay(DateTime date) {
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          if (_selectedDays.contains(date))
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              height: 20,
              child: Container(
                color: Colors.lightBlueAccent,
              ),
            ),
          Positioned(
            left: 4,
            top: 4,
            child: Text(
              '${date.day}',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventMarker(DateTime date) {
    return _buildDefaultDay(date);
  }

  Widget _buildTodayMarker(DateTime date) {
    return Container(
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: Text(
              '${date.day}',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDay(DateTime date) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          // 현재 날짜와 연결된 이벤트 목록을 찾음
          String? eventKey;
          for (var key in _eventDates.keys) {
            if (_eventDates[key]!.contains(date)) {
              eventKey = key;
              break;
            }
          }
          // 해당 이벤트가 있으면 삭제
          if (eventKey != null) {
            for (var eventDate in _eventDates[eventKey]!) {
              _events.remove(eventDate);
              _selectedDays.remove(eventDate);
            }
            _eventDates.remove(eventKey);
          }
        });
      },
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Stack(
          children: [
            if (_selectedDays.contains(date) || _events.containsKey(date))
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                height: 20,
                child: Container(
                  color: _selectedDays.contains(date)
                      ? Colors.lightBlueAccent.withOpacity(0.5)
                      : _events.containsKey(date)
                      ? Colors.green.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
            Positioned(
              left: 4,
              top: 4,
              child: Text(
                '${date.day}',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            if (_events.containsKey(date))
              Positioned(
                left: 4,
                bottom: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _events[date]!
                      .map((event) => Text(
                    event,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showActivityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['공부', '휴식', '여행', '기타'].map((activity) {
              return ListTile(
                title: Text(activity),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    // 각 날짜에 이벤트 추가
                    for (var day in _selectedDays) {
                      if (!_events.containsKey(day)) {
                        _events[day] = [];
                      }
                      _events[day]!.add(activity);
                    }
                    // 이벤트 목록 저장
                    String eventKey = '${_firstSelectedDay.toString()}_${_secondSelectedDay.toString()}_$activity';
                    _eventDates[eventKey] = List.from(_selectedDays);
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
