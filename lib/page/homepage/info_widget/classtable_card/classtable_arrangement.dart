// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/class_detail_tile.dart';
import 'package:watermeter/page/widget.dart';

class ClasstableArrangementColumn extends StatelessWidget {
  const ClasstableArrangementColumn({super.key});

  @override
  Widget build(BuildContext context) {
    Widget noticeBox(String text) {
      Widget textWidget = Text(text)
          .center()
          .padding(
            horizontal: 8,
            vertical: 6,
          )
          .backgroundColor(
            Colors.grey.shade200,
          )
          .clipRRect(all: 12)
          .center();

      if (!isPhone(context)) {
        return textWidget.center().expanded();
      } else {
        return textWidget;
      }
    }

    return GetBuilder<ClassTableController>(
      builder: (c) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "接下来课程",
            style: TextStyle(
              fontSize: 14,
              textBaseline: TextBaseline.alphabetic,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).padding(bottom: 8.0),
          if (c.isGet)
            if (c.classSet.$1.isNotEmpty) ...[
              ClassDetailTile(
                isTomorrow: c.classSet.$2,
                name: c
                    .classTableData.classDetail[c.classSet.$1.first.index].name,
                time: '${time[(c.classSet.$1.first.start - 1) * 2]}'
                    '-${time[(c.classSet.$1.first.stop - 1) * 2 + 1]}',
                place: c.classSet.$1.first.classroom ?? "未定教室",
              ),
              noticeBox(
                  "${c.classSet.$2 ? "明天一共" : "今天还剩"}${c.classSet.$1.length}节课"),
            ] else
              noticeBox(c.classSet.$2 ? "明天没有课" : "今天课程上完了")
          else
            noticeBox(c.error == null ? "正在加载" : "遇到错误"),
        ],
      ),
    );
  }
}