import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';

class ClassTableDateRow extends StatelessWidget {
  final List<DateTime> dateList = [];
  ClassTableDateRow({super.key, required DateTime firstDay}) {
    dateList.addAll(List.generate(7, (i) => firstDay.add(Duration(days: i))));
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.sizeOf(context);
    return Container(
      height: mediaQuerySize.width / mediaQuerySize.height >= 1.20
          ? midRowHeightHorizontal
          : midRowHeightVertical,
      padding: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.grey.shade200.withOpacity(0.75),
      child: Row(
        children: List.generate(8, (index) {
          if (index > 0) {
            return WeekInfomation(time: dateList[index - 1]);
          } else {
            return SizedBox(
              width: leftRow,
              child: Center(
                child: AutoSizeText(
                  "课次",
                  textAlign: TextAlign.center,
                  group: AutoSizeGroup(),
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

class WeekInfomation extends StatelessWidget {
  final DateTime time;
  const WeekInfomation({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    bool isToday =
        (time.month == DateTime.now().month && time.day == DateTime.now().day);
    Size mediaQuerySize = MediaQuery.of(context).size;
    bool isHorizontal() => mediaQuerySize.width / mediaQuerySize.height > 1;
    var list = [
      AutoSizeText(
        weekList[time.weekday - 1],
        group: AutoSizeGroup(),
        textScaleFactor: 1.0,
        style: TextStyle(
          //fontSize: 14,
          color: isToday ? Colors.lightBlue : Colors.black87,
        ),
      ),
      isHorizontal() ? const SizedBox(width: 5) : const SizedBox(height: 5),
      AutoSizeText(
        "${time.month}/${time.day}",
        group: AutoSizeGroup(),
        textScaleFactor: isHorizontal() ? 1.0 : 0.8,
        style: TextStyle(
          color: isToday ? Colors.lightBlue : Colors.black87,
        ),
      ),
    ];
    return Container(
      width: (mediaQuerySize.width - leftRow) / 7,
      color: isToday ? const Color(0x00f7f7f7) : Colors.transparent,
      child: mediaQuerySize.width / mediaQuerySize.height >= 1.20
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: list,
            ),
    );
  }
}
