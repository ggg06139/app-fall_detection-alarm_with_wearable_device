import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'home_page.dart';
import 'main.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
      pageColor: Color.fromARGB(255, 206, 236, 207),
      titlePadding: EdgeInsets.fromLTRB(16.0, 75.0, 16.0, 0.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
    );
    return Scaffold(
      body: IntroductionScreen(
        globalFooter: SizedBox(
          width: double.infinity,
        ),
        pages: [
          // 첫 번째 페이지
          PageViewModel(
            title: "낙상 알람 어플: 도담이",
            body:
                "'무탈하고 건강하다'라는 의미인\n순우리말 '도담'에서 착안한 '도담이'는\n사용자의 건강을 지키는 어플입니다.",
            image: Container(
              margin: EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/logo.png',
                height: double.infinity,
              ),
            ),
            decoration: pageDecoration,
          ),
          // 두 번째 페이지
          PageViewModel(
            title: "시작하세요",
            body: "'도담이'를 통해 낙상 후 2차 위험으로부터\n사랑하는 가족들을 지켜내세요",
            image: Container(
              margin: EdgeInsets.only(top: 100),
              child: Image.asset(
                'assets/start.png',
                height: double.infinity,
              ),
            ),
            decoration: pageDecoration,
          ),
        ],
        dotsDecorator: DotsDecorator(
          activeColor: Colors.green,
          size: Size(10, 10),
          activeSize: Size(22, 10),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        controlsPosition: const Position(left: 0, right: 0, bottom: -7),
        next: Text(
          "다음   →",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 41, 102, 43),
          ),
        ),
        done: Text(
          "시작하기",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 41, 102, 43),
          ),
        ),
        onDone: () {
          // Done 클릭시 isOnboarded = true로 저장해야 다음 실행부터 로그인/홈페이지로 이동
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
