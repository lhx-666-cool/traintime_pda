/*
Login window of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:watermeter/main.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:watermeter/repository/general.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/widget.dart';

class LoginWindow extends StatefulWidget {
  const LoginWindow({Key? key}) : super(key: key);

  @override
  State<LoginWindow> createState() => _LoginWindowState();
}

class _LoginWindowState extends State<LoginWindow> {
  /// The rest of Text Editing Controller
  final TextEditingController _idsAccountController = TextEditingController();
  final TextEditingController _idsPasswordController = TextEditingController();

  /// Can I see the password?
  bool _couldNotView = true;

  void _login(String? captcha) async {
    bool isGood = true;
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      msg: '正在登录学校一站式',
      max: 100,
      hideValue: true,
      completed: Completed(completedMsg: "登录成功"),
    );
    try {
      await ses.loginEhall(
        username: _idsAccountController.text,
        password: _idsPasswordController.text,
        captcha: captcha,
        onResponse: (int number, String status) =>
            pd.update(msg: status, value: number),
      );
      if (!mounted) return;
      if (isGood == true) {
        addUser("idsAccount", _idsAccountController.text);
        addUser("idsPassword", _idsPasswordController.text);
        await ses.getInformation();
        if (mounted) {
          if (pd.isOpen()) pd.close();
          Get.off(const HomePage());
        }
      }
    } catch (e) {
      isGood = false;
      pd.close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Temporary symbol of watermeter.
          const CircleAvatar(
            backgroundImage: AssetImage("assets/Login-Background.jpg"),
            radius: 60.0,
          ),
          const SizedBox(height: 15.0),
          const Text('请登录 Watermeter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              )),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(roundRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  autofocus: true,
                  controller: _idsAccountController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "学号",
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(roundRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: TextField(
                  controller: _idsPasswordController,
                  obscureText: _couldNotView,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "一站式登录密码",
                    suffixIcon: IconButton(
                        icon: Icon(_couldNotView
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _couldNotView = !_couldNotView;
                          });
                        }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA267AC),
                padding: const EdgeInsets.all(20.0),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(roundRadius)),
              ),
              child: const Text(
                "登录",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ),
              onPressed: () async {
                if (_idsAccountController.text.length == 11 &&
                    _idsPasswordController.text.isNotEmpty) {
                  String? captcha;
                  await ses.initLogin(
                      target:
                          "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html");

                  /// Check captcha.
                  bool isNeedCaptcha = await ses.captchaCheck(
                      username: _idsAccountController.text);
                  var cookie = await IDSCookieJar.loadForRequest(
                      Uri.parse("http://ids.xidian.edu.cn/authserver"));
                  String cookieStr = "";
                  for (var i in cookie) {
                    cookieStr += "${i.name}=${i.value}; ";
                  }
                  if (mounted && isNeedCaptcha) {
                    print("需要验证码");
                    captcha = await showDialog<String>(
                        context: context,
                        builder: ((context) => CaptchaInputDialog(
                            cookie:
                                cookieStr.substring(0, cookieStr.length - 2))));
                    if (captcha == null) return;
                  }
                  _login(captcha);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('用户名或密码不符合要求，学号必须 11 位且密码非空'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text(
                  '清除登录缓存',
                  style: TextStyle(
                    color: Color(0xFFA267AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  IDSCookieJar.deleteAll().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('清理缓存成功'),
                      ),
                    ),
                  );
                },
              ),
              TextButton(
                child: const Text(
                  '查看缓存设定',
                  style: TextStyle(
                    color: Color(0xFFA267AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  alice.showInspector();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class CaptchaInputDialog extends StatelessWidget {
  final TextEditingController _captchaController = TextEditingController();
  String cookie;

  CaptchaInputDialog({super.key, required this.cookie});

  @override
  Widget build(BuildContext context) {
    NetworkImage cappic = NetworkImage(
        "https://ids.xidian.edu.cn/authserver/getCaptcha.htl",
        headers: {"Cookie": cookie});

    return AlertDialog(
      title: const Text('请输入验证码'),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: Column(
        children: [
          Image(image: cappic),
          TextField(
            autofocus: true,
            style: const TextStyle(fontSize: 20),
            controller: _captchaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "输入验证码",
              fillColor: Colors.grey.withOpacity(0.4),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('提交'),
          onPressed: () async {
            if (_captchaController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('请输入验证码'),
                ),
              );
            } else {
              Navigator.of(context).pop(_captchaController.text);
            }
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
