// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/electricity_session.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/ehall_exam_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

enum ExamStatus {
  cache,
  fetching,
  fetched,
  error,
  none,
}

class ExamController extends GetxController {
  static const examDataCacheName = "exam.json";

  ExamStatus status = ExamStatus.none;
  String error = "";
  late ExamData data;
  late File file;

  List<HomeArrangement> getExamOfDate(DateTime now) {
    List<Subject> isFinished = List.from(data.subject);

    isFinished.removeWhere(
      (element) => !element.startTime.isSame(
        Jiffy.parseFromDateTime(now),
        unit: Unit.day,
      ),
    );
    return isFinished
        .map((e) => HomeArrangement(
              name: e.subject,
              place: "${e.place} ${e.seat}座",
              startTimeStr: e.startTime.format(pattern: HomeArrangement.format),
              endTimeStr: e.stopTime.format(pattern: HomeArrangement.format),
            ))
        .toList();
  }

  List<Subject> isFinished(DateTime now) {
    List<Subject> isFinished = List.from(data.subject);
    isFinished.removeWhere(
      (element) => element.startTime.isAfter(
        Jiffy.parseFromDateTime(now),
      ),
    );
    return isFinished;
  }

  List<Subject> isNotFinished(DateTime now) {
    List<Subject> isNotFinished = List.from(data.subject);
    isNotFinished.removeWhere(
      (element) => element.startTime.isSameOrBefore(
        Jiffy.parseFromDateTime(now),
      ),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.startTime.microsecondsSinceEpoch -
            b.startTime.microsecondsSinceEpoch,
      );
  }

  @override
  void onInit() {
    super.onInit();
    log.i(
      "[ExamController][onInit] "
      "Path at ${supportPath.path}.",
    );
    file = File("${supportPath.path}/$examDataCacheName");
    bool isExist = file.existsSync();

    if (isExist) {
      log.i(
        "[ExamController][onInit] "
        "Init from cache.",
      );
      data = ExamData.fromJson(jsonDecode(file.readAsStringSync()));
      status = ExamStatus.cache;
    } else {
      data = ExamData(subject: [], toBeArranged: []);
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get().then((value) => update());
  }

  Future<void> get() async {
    ExamStatus previous = status;
    log.i(
      "[ExamController][get] "
      "Fetching data from Internet.",
    );
    try {
      status = ExamStatus.fetching;
      data = await ExamSession().getExam();
      status = ExamStatus.fetched;
      error = "";
    } on DioException catch (e, s) {
      log.w(
        "[ExamController][get] "
        "Network exception",
        error: e,
        stackTrace: s,
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      log.w(
        "[ExamController][get] "
        "Exception",
        error: e,
        stackTrace: s,
      );
    } finally {
      if (status == ExamStatus.fetched) {
        log.i(
          "[ExamController][get] "
          "Store to cache.",
        );
        file.writeAsStringSync(jsonEncode(
          data.toJson(),
        ));
        if (Platform.isIOS) {
          final api = SaveToGroupIdSwiftApi();
          try {
            bool result = await api.saveToGroupId(FileToGroupID(
              appid: preference.appId,
              fileName: "ExamFile.json",
              data: jsonEncode(jsonEncode(data.toJson())),
            ));
            log.i(
              "[ExamController][get] "
              "ios Save to public place status: $result.",
            );
          } catch (e, s) {
            log.w(
              "[ExamController][get] "
              "ios Save to public place failed with error: ",
              error: e,
              stackTrace: s,
            );
          }
        }
      } else if (previous == ExamStatus.cache) {
        status = ExamStatus.cache;
      } else {
        status = ExamStatus.error;
      }
    }
    update();
  }
}
