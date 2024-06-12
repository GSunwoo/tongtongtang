import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class ScheduleItem {
  int startRow;
  int endRow;
  String name;

  ScheduleItem(this.startRow, this.endRow, this.name);
}

class _WeekViewState extends State<WeekView> {
  List<String> daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
  List<String> hoursOfDay = List.generate(24, (index) => "${(7 + index) % 24}:00");

  Map<int, List<ScheduleItem>> scheduleMap = {};
  int? startRow;
  int? selectedColumn;
  int? endRow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주간 시간표'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(60),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                Container(height: 30, child: Center(child: Text('시간/요일'))),
                for (var day in daysOfWeek) Container(height: 30, child: Center(child: Text(day))),
              ],
            ),
            for (int row = 0; row < hoursOfDay.length; row++)
              TableRow(
                children: [
                  Container(height: 40, child: Center(child: Text(hoursOfDay[row]))),
                  for (int col = 0; col < daysOfWeek.length; col++)
                    GestureDetector(
                      onTap: () => _handleCellTap(row, col),
                      onDoubleTap: () => _handleCellDoubleTap(row, col),
                      child: Container(
                        color: _getCellColor(row, col),
                        height: 40,
                        child: Center(child: Text(_getText(row, col))),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleCellTap(int row, int col) {
    setState(() {
      if (selectedColumn == col && startRow != null && endRow == null) {
        endRow = row;
        _showActivityDialog(col, startRow!, endRow!);
      } else {
        startRow = row;
        selectedColumn = col;
        endRow = null; // Reset end row on new selection or column change
      }
    });
  }

  void _handleCellDoubleTap(int row, int col) {
    setState(() {
      var schedules = scheduleMap[col];
      if (schedules != null) {
        schedules.removeWhere((item) => item.startRow <= row && item.endRow >= row);
      }
    });
  }

  void _showActivityDialog(int col, int start, int end) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Activity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['공부', '휴식', '친구', '기타'].map((activity) {
              return ListTile(
                title: Text(activity),
                onTap: () {
                  Navigator.of(context).pop();
                  int minRow = math.min(start, end);
                  int maxRow = math.max(start, end);
                  ScheduleItem newItem = ScheduleItem(minRow, maxRow, activity);
                  scheduleMap[col] = (scheduleMap[col] ?? [])..add(newItem);
                  setState(() {});
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getText(int row, int col) {
    var items = scheduleMap[col];
    if (items != null) {
      for (var item in items) {
        if (item.startRow == row) { // 일정의 시작 셀인지 확인
          return item.name;
        }
      }
    }
    return '';
  }

  Color _getCellColor(int row, int col) {
    var items = scheduleMap[col];
    bool isWithinSelectedRange = selectedColumn == col && startRow != null &&
        endRow != null && row >= math.min(startRow!, endRow!) &&
        row <= math.max(startRow!, endRow!);

    if (col == selectedColumn && row == startRow) {
      return Colors.lightBlueAccent;
    } else if (isWithinSelectedRange) {
      // 선택 범위 내의 셀은 파란색으로 표시
      return Colors.lightBlueAccent;
    } else if (items != null) {
      for (var item in items) {
        if (item.startRow <= row && item.endRow >= row) {
          return Colors.green;  // 일정이 추가된 셀은 녹색으로 표시
        }
      }
    }
    return Colors.transparent; // 기본 색상
  }
}
