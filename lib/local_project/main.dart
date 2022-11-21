import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bucket_service.dart';

late SharedPreferences prefs;

void main() async {
  // main() 함수에서 async를 쓰려면 필요
  WidgetsFlutterBinding.ensureInitialized();

  // shared_preferences 인스턴스 생성
  prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BucketService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SharedPreferences에서 온보딩 완료 여부 조회
    // isOnboarded에 해당하는 값에서 null을 반환하는 경우 false 할당
    bool isOnboarded = prefs.getBool("isOnboarded") ?? false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.getTextTheme('IBM Plex Sans KR'),
      ),
      home: isOnboarded ? HomePage() : OnboardingPage(),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          // 첫 번째 페이지
          PageViewModel(
            title: "낙상 알람 앱",
            body: "낙상 시 보호자의 스마트폰으로 알람이 갑니다.",
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          // 두 번째 페이지
          PageViewModel(
            title: "시작하세요",
            body: "안전을 위한 앱, 지금 바로 시작하세요.",
            decoration: PageDecoration(
              titleTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
        ],
        next: Text("Next", style: TextStyle(fontWeight: FontWeight.w600)),
        done: Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
        onDone: () {
          // Done 클릭시 isOnboarded = true로 저장
          prefs.setBool("isOnboarded", true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
    );
  }
}

/// 버킷 클래스
class Bucket {
  String job; // 할 일
  bool isDone; // 완료 여부

  Bucket(this.job, this.isDone); // 생성자
}

/// 홈 페이지
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BucketService>(
      builder: (context, bucketService, child) {
        List<Bucket> bucketList = bucketService.bucketList;
        return Scaffold(
          appBar: AppBar(
            title: Text("버킷 리스트"),
          ),
          body: bucketList.isEmpty
              ? Center(child: Text("버킷 리스트를 작성해 주세요."))
              : ListView.builder(
                  itemCount: bucketList.length, // bucketList 개수 만큼 보여주기
                  itemBuilder: (context, index) {
                    var bucket = bucketList[index]; // index에 해당하는 bucket 가져오기
                    return ListTile(
                      // 버킷 리스트 할 일
                      title: Text(
                        bucket.job,
                        style: TextStyle(
                          fontSize: 24,
                          color: bucket.isDone ? Colors.grey : Colors.black,
                          decoration: bucket.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      // 삭제 아이콘 버튼
                      trailing: IconButton(
                        icon: Icon(CupertinoIcons.delete),
                        onPressed: () {
                          // 삭제 버튼 클릭시
                          bucketService.deleteBucket(index);
                        },
                      ),
                      onTap: () {
                        // 아이템 클릭시
                        bucket.isDone = !bucket.isDone;
                        bucketService.updateBucket(bucket, index);
                      },
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              // + 버튼 클릭시 버킷 생성 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePage()),
              );
            },
          ),
        );
      },
    );
  }
}

/// 버킷 생성 페이지
class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // TextField의 값을 가져올 때 사용합니다.
  TextEditingController textController = TextEditingController();

  // 경고 메세지
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("버킷리스트 작성"),
        // 뒤로가기 버튼
        leading: IconButton(
          icon: Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 텍스트 입력창
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "하고 싶은 일을 입력하세요",
                errorText: error,
              ),
            ),
            SizedBox(height: 32),
            // 추가하기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                child: Text(
                  "추가하기",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  // 추가하기 버튼 클릭시
                  String job = textController.text;
                  if (job.isEmpty) {
                    setState(() {
                      error = "내용을 입력해주세요."; // 내용이 없는 경우 에러 메세지
                    });
                  } else {
                    setState(() {
                      error = null; // 내용이 있는 경우 에러 메세지 숨기기
                    });
                    // BucketService 가져오기
                    BucketService bucketService = context.read<BucketService>();
                    bucketService.createBucket(job);
                    Navigator.pop(context); // 화면을 종료합니다.
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
