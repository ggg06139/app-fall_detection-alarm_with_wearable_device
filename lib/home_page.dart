import 'package:fall_alert_app/record_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'login_page.dart';

/// Record 클래스
class Record {
  String time; // 할 일
  bool isDone; // 완료 여부

  Record(this.time, this.isDone); // 생성자
}

/// 홈 페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Record> recordList = []; // 전체 버킷리스트 목록

  @override
  Widget build(BuildContext context) {
    String getToday() {
      DateTime now = DateTime.now();
      DateFormat formatter = DateFormat('yyyy년 MM월 dd일  kk시 mm분 ss초');
      String strToday = formatter.format(now);
      return strToday;
    }

    return Consumer<RecordService>(
      builder: (context, recordService, child) {
        List<Record> recordList = recordService.recordList;
        return Scaffold(
          appBar: AppBar(
            title: Text("대시보드"),
            actions: [
              TextButton(
                child: Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  // 로그아웃
                  context.read<AuthService>().signOut();

                  // 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
            backgroundColor: Colors.green,
          ),
          body: recordList.isEmpty
              ? Center(
                  child: Text(
                  "낙상 감지 이력이 없습니다.",
                  style: TextStyle(fontSize: 15),
                ))
              : ListView.builder(
                  itemCount: recordList.length, // recordList 개수 만큼 보여주기
                  itemBuilder: (context, index) {
                    Record record =
                        recordList[index]; // index에 해당하는 record 가져오기
                    return ListTile(
                      // 버킷 리스트 할 일
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "낙상 감지",
                            style: TextStyle(
                              fontSize: 20,
                              color: record.isDone ? Colors.grey : Colors.black,
                              decoration: record.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          Text(
                            record.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: record.isDone ? Colors.grey : Colors.black,
                              decoration: record.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      // 삭제 아이콘 버튼
                      trailing: IconButton(
                        icon: Icon(CupertinoIcons.delete),
                        onPressed: () {
                          // 삭제 버튼 클릭시
                          showDeleteDialog(context, index);
                        },
                      ),
                      onTap: () {
                        // 아이템 클릭시
                        setState(() {
                          record.isDone = !record.isDone;
                          recordService.updateRecord(record, index);
                        });
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
            onPressed: () {
              String time = getToday();
              setState(
                () {
                  RecordService recordService = context.read<RecordService>();
                  recordService.createRecord(time);
                },
              );
            },
          ),
        );
      },
    );
  }

  void showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("정말로 삭제하시겠습니까?"),
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            // 확인 버튼
            TextButton(
              onPressed: () {
                setState(() {
                  // 삭제
                  RecordService recordService = context.read<RecordService>();
                  recordService.deleteRecord(index);
                });
                Navigator.pop(context);
              },
              child: Text(
                "확인",
                style: TextStyle(color: Colors.pink),
              ),
            ),
          ],
        );
      },
    );
  }
}
