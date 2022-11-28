import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'bucket_service.dart';
import 'login_page.dart';

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<BucketService>(
      builder: (context, bucketService, child) {
        final authService = context.read<AuthService>();
        User user = authService.currentUser()!;
        return Scaffold(
          appBar: AppBar(
            title: Text("버킷 리스트"),
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
          ),
          body: Column(
            children: [
              /// 입력창
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    /// 텍스트 입력창
                    Expanded(
                      child: TextField(
                        controller: jobController,
                        decoration: InputDecoration(
                          hintText: "하고 싶은 일을 입력해주세요.",
                        ),
                      ),
                    ),

                    /// 추가 버튼
                    ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        // create bucket
                        if (jobController.text.isNotEmpty) {
                          bucketService.create(jobController.text, user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1),

              /// 버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future: bucketService.read(user.uid),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? [];
                      if (documents.isEmpty) {
                        return Text("버킷 리스트를 작성해 주세요.");
                      }
                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String job = doc.get("job");
                          bool isDone = doc.get("isDone");
                          return ListTile(
                            title: Text(
                              job,
                              style: TextStyle(
                                fontSize: 24,
                                color: isDone ? Colors.grey : Colors.black,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            // 삭제 아이콘 버튼
                            trailing: IconButton(
                              icon: Icon(CupertinoIcons.delete),
                              onPressed: () {
                                // 삭제 버튼 클릭시
                                bucketService.delete(doc.id);
                              },
                            ),
                            onTap: () {
                              // 아이템 클릭하여 isDone 업데이트
                              bucketService.update(doc.id, !isDone);
                            },
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }
}
