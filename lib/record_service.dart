import 'package:flutter/material.dart';

import 'home_page.dart';

/// record 담당
class RecordService extends ChangeNotifier {
  List<Record> recordList = [
    Record('잠자기', false), // 더미(dummy) 데이터
  ];

  /// record 추가
  void createRecord(String time) {
    recordList.add(Record(time, false));
    notifyListeners(); // 갱신 = Consumer<BucketService>의 builder 부분만 새로고침
  }

  /// record 수정
  void updateRecord(Record record, int index) {
    recordList[index] = record;
    notifyListeners();
  }

  /// record 삭제
  void deleteRecord(int index) {
    recordList.removeAt(index);
    notifyListeners();
  }
}
