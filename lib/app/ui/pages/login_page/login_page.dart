import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/login_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:ysy_kargo_panel/core/base_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
        init: LoginController(),
        builder: (c) {
          return Scaffold(
            backgroundColor: ColorManager.instance.white,
            body: Center(
              child: AnimatedHover(
                curve: Curves.fastOutSlowIn,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 120,
                      height: 120,
                    ),
                    SelectableText(
                      "Yönetici Paneline\nHoş geldiniz",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 360,
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                child: TextFormField(
                                  controller: c.emailController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hoverColor: Colors.white,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "E-posta",
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              child: TextFormField(
                                controller: c.passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hoverColor: Colors.white,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Şifre",
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            KargoButton(
                                buttonColor: ColorManager.instance.black,
                                width: Utility.dynamicWidthPixel(80),
                                textStyle: TextStyle(fontSize: Utility.dynamicTextSize(6), color: ColorManager.instance.white),
                                text: "Giriş Yap",
                                onTap: () {
                                  c.login();
                                }),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class AnimatedHover extends StatefulWidget {
  final Widget child;
  final Size size;
  final Color hoverColor, bgColor;
  final Offset offset;
  final Curve curve;
  final Duration duration;
  final Border border;
  const AnimatedHover({
    super.key,
    required this.child,
    this.size = const Size(440, 440),
    this.bgColor = const Color(0xffe9eff3),
    this.hoverColor = const Color(0xffff5a00),
    this.offset = const Offset(2, -2),
    this.curve = Curves.easeOutBack,
    this.duration = const Duration(milliseconds: 400),
    this.border = const Border(),
  });

  @override
  State<AnimatedHover> createState() => _AnimatedHoverState();
}

class _AnimatedHoverState extends State<AnimatedHover> {
  bool _isHover = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: widget.size.height,
          width: widget.size.width,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        AnimatedPositioned(
          duration: widget.duration,
          curve: widget.curve,
          top: _isHover ? widget.offset.dy : 0,
          right: _isHover ? widget.offset.dx : 0,
          child: InkWell(
            onTap: () {},
            onHover: (value) {
              setState(() {
                _isHover = value;
              });
            },
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            child: Container(
              height: widget.size.height,
              width: widget.size.width,
              decoration: BoxDecoration(
                color: _isHover ? widget.hoverColor : widget.bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: widget.border,
              ),
              child: widget.child,
            ),
          ),
        )
      ],
    );
  }
}
