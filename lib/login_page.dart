import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'home_page.dart';
import 'main.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        User? user = authService.currentUser();
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 80),
                  child: Image.asset("assets/login.png", height: 120),
                ),

                /// 현재 유저 로그인 상태
                Center(
                  child: Text(
                    user == null ? "계정 로그인" : "${user.email}님 반갑습니다.",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
                SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      /// 이메일
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(hintText: "이메일"),
                      ),

                      /// 비밀번호
                      TextField(
                        controller: passwordController,
                        obscureText: true, // 비밀번호 안보이게
                        decoration: InputDecoration(hintText: "비밀번호"),
                      ),
                    ],
                  ),
                ),

                /// 로그인 버튼
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[300]),
                    child: Text("로그인", style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      // 로그인
                      authService.signIn(
                        email: emailController.text,
                        password: passwordController.text,
                        onSuccess: () {
                          // 로그인 성공
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("로그인 성공"),
                          ));

                          // HomePage로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );

                          // 다음 실행 시 온보드 페이지 활성화
                          prefs.setBool("isOnboarded", false);
                        },
                        onError: (err) {
                          // 에러 발생
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(err),
                          ));
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 150),

                /// 회원가입 버튼
                TextButton(
                  child: Text("계정이 없으십니까? 회원가입하기",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                  onPressed: () {
                    // 회원가입
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 회원가입 성공
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("회원가입 성공"),
                        ));
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err),
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
