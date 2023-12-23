// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ScoreState extends InheritedWidget {
  /// Static data.
  final List<Score> scoreTable;
  final Set<String> semester;
  final Set<String> statuses;
  final Set<String> unPassedSet;
  final String currentSemester;

  /// Parent's Buildcontext.
  final BuildContext context;

  /// Changeable state.
  final ScoreWidgetState controllers;

  /// Exclude these from counting avgs
  /// 1. CET-4 and CET-6
  /// 2. Teacher have not finish uploading scores
  /// 3. Have score below 60 but passed.
  /// 4. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains("国家英语四级") ||
      eval.name.contains("国家英语六级") ||
      eval.name.contains(notFinish) ||
      (eval.score < 60 && !unPassedSet.contains(eval.name)) ||
      (eval.name.contains(notFirstTime) && eval.score < 60));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  /// [isGPA] true for the GPA, false for the avgScore
  double evalAvg(bool isAll, {bool isGPA = false}) {
    double totalScore = 0.0;
    double totalCredit = evalCredit(isAll);
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalScore += (isGPA ? scoreTable[i].gpa : scoreTable[i].score) *
            scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (controllers.chosenSemester != "") {
      whatever.removeWhere(
        (element) => element.year != controllers.chosenSemester,
      );
    }
    if (controllers.chosenStatus != "") {
      whatever.removeWhere(
        (element) => element.status != controllers.chosenStatus,
      );
    }
    return whatever;
  }

  List<Score> get getSelectedScoreList => List.from(scoreTable)
    ..removeWhere((element) => !controllers.isSelected[element.mark]);

  List<Score> get selectedScoreList {
    List<Score> whatever = List.from(getSelectedScoreList);
    if (controllers.chosenSemesterInScoreChoice != "") {
      whatever.removeWhere(
        (element) => element.year != controllers.chosenSemesterInScoreChoice,
      );
    }
    if (controllers.chosenStatusInScoreChoice != "") {
      whatever.removeWhere(
        (element) => element.status != controllers.chosenStatusInScoreChoice,
      );
    }
    return whatever;
  }

  String get unPassed => unPassedSet.isEmpty ? "没有" : unPassedSet.join(",");

  String get bottomInfo =>
      "目前选中科目 ${getSelectedScoreList.length}  总计学分 ${evalCredit(false).toStringAsFixed(2)}\n"
      "均分 ${evalAvg(false).toStringAsFixed(2)}  "
      "GPA ${evalAvg(false, isGPA: true).toStringAsFixed(2)}  ";

  double get notCoreClass {
    double toReturn = 0.0;
    for (var i in scoreTable) {
      if (i.status.contains(notCoreClassType) && i.score >= 60) {
        toReturn += i.credit;
      }
    }
    return toReturn;
  }

  factory ScoreState.init({
    required List<Score> scoreTable,
    required Widget child,
    required BuildContext context,
  }) {
    Set<String> semester = {for (var i in scoreTable) i.year};
    Set<String> statuses = {for (var i in scoreTable) i.status};
    Set<String> unPassedSet = {
      for (var i in scoreTable)
        if (i.score < 60) i.name
    };
    return ScoreState._(
      scoreTable: scoreTable,
      currentSemester: preference.getString(
        preference.Preference.currentSemester,
      ),
      controllers: ScoreWidgetState(
        isSelected: List<bool>.generate(
          scoreTable.length,
          (int index) {
            for (var i in courseIgnore) {
              if (scoreTable[index].name.contains(i)) return false;
            }
            for (var i in statusIgnore) {
              if (scoreTable[index].status.contains(i)) return false;
            }
            return true;
          },
        ),
      ),
      semester: semester,
      statuses: statuses,
      unPassedSet: unPassedSet,
      context: context,
      child: child,
    );
  }

  const ScoreState._({
    required super.child,
    required this.scoreTable,
    required this.controllers,
    required this.semester,
    required this.statuses,
    required this.unPassedSet,
    required this.currentSemester,
    required this.context,
  });

  void setScoreChoiceMod() {
    controllers.isSelectMod = !controllers.isSelectMod;
    controllers.notifyListeners();
  }

  void setScoreChoiceFromIndex(int index) {
    controllers.isSelected[index] = !controllers.isSelected[index];
    controllers.notifyListeners();
  }

  void setScoreChoiceState(ChoiceState state) {
    for (var stuff in toShow) {
      if (state == ChoiceState.all) {
        controllers.isSelected[stuff.mark] = true;
      } else if (state == ChoiceState.none) {
        controllers.isSelected[stuff.mark] = false;
      } else if (courseIgnore.contains(scoreTable[stuff.mark].name) ||
          scoreTable[stuff.mark].status.contains(scoreTable[stuff.mark].name)) {
        controllers.isSelected[stuff.mark] = false;
      } else {
        controllers.isSelected[stuff.mark] = true;
      }
    }
    controllers.notifyListeners();
  }

  set chosenSemester(String str) {
    controllers.chosenSemester = str;
    controllers.notifyListeners();
  }

  set chosenStatus(String str) {
    controllers.chosenStatus = str;
    controllers.notifyListeners();
  }

  void chosenSemesterInScoreChoice(String str) {
    controllers.chosenSemesterInScoreChoice = str;
    controllers.notifyListeners();
  }

  void chosenStatusInScoreChoice(String str) {
    controllers.chosenStatusInScoreChoice = str;
    controllers.notifyListeners();
  }

  static ScoreState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScoreState>();
  }

  @override
  bool updateShouldNotify(covariant ScoreState oldWidget) {
    ScoreWidgetState newState = controllers;
    ScoreWidgetState oldState = oldWidget.controllers;

    return (!listEquals(oldState.isSelected, newState.isSelected) ||
        oldState.chosenSemester != newState.chosenSemester ||
        oldState.chosenStatus != newState.chosenStatus ||
        oldState.chosenSemesterInScoreChoice !=
            newState.chosenSemesterInScoreChoice ||
        oldState.chosenStatusInScoreChoice !=
            newState.chosenStatusInScoreChoice);
  }
}

class ScoreWidgetState extends ChangeNotifier {
  /// Is score is selected to count.
  List<bool> isSelected;

  /// Is select mod?
  bool isSelectMod = false;

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Empty means all semester, especially in score choice window.
  String chosenSemesterInScoreChoice = "";

  /// Empty means all status, especially in score choice window.
  String chosenStatusInScoreChoice = "";

  ScoreWidgetState({
    required this.isSelected,
  });

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}