/*import 'package:cargo_app/app/controller/profile_controller.dart';
import 'package:cargo_app/app/ui/global_widgets/button.dart';
import 'package:cargo_app/app/ui/global_widgets/c_textformfield.dart';
import 'package:cargo_app/app/utils/color_manager.dart';
import 'package:cargo_app/core/base_state.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.instance.white,
      body: FutureBuilder(
          future: FirebaseDatabase.instance.ref().child('users').child("${FirebaseAuth.instance.currentUser?.uid}").get(),
          builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
            if (snapshot.hasData) {
              Map<dynamic, dynamic> user = snapshot.data!.value as Map<dynamic, dynamic>;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: GetBuilder<ProfileController>(
                          init: ProfileController(),
                          builder: (c) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: Utility.dynamicWidthPixel(20)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  KargoTextFormField(
                                    title: "İsim",
                                    textEditingController: c.nameController..text = user["name"] ?? "",
                                  ),
                                  SizedBox(
                                    height: Utility.dynamicWidthPixel(20),
                                  ),
                                  KargoTextFormField(
                                    title: "Soyisim",
                                    textEditingController: c.surnameController..text = user["surname"] ?? "",
                                  ),
                                  SizedBox(
                                    height: Utility.dynamicWidthPixel(20),
                                  ),
                                  KargoTextFormField(
                                    title: "E-posta",
                                    readOnly: true,
                                    enabled: false,
                                    textEditingController: c.emailController..text = user["email"] ?? "",
                                  ),
                                  SizedBox(
                                    height: Utility.dynamicWidthPixel(20),
                                  ),
                                  KargoTextFormField(
                                    title: "Telefon Numarası",
                                    onChanged: (value) {
                                      if (!value.startsWith('90')) {
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          c.phoneController.text = '90 ';
                                          c.update();
                                        });
                                      }
                                    },
                                    mask: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(12),
                                    ],
                                    textEditingController: c.phoneController..text = user["phone"] ?? "",
                                  ),
                                  SizedBox(
                                    height: Utility.dynamicWidthPixel(20),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Utility.dynamicWidthPixel(20)),
                      child: GetBuilder<ProfileController>(
                          init: ProfileController(),
                          builder: (c) {
                            return KargoButton(
                                buttonColor: ColorManager.instance.white,
                                borderColor: ColorManager.instance.orange,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: ColorManager.instance.orange,
                                ),
                                text: "Güncelle",
                                onTap: () {
                                  c.updateProfile(context);
                                });
                          }),
                    ),
                    SizedBox(
                      height: Utility.dynamicWidthPixel(20),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Utility.dynamicWidthPixel(20)),
                      child: KargoButton(
                        buttonColor: ColorManager.instance.orange,
                        text: "Çıkış Yap",
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                        },
                      ),
                    ),
                    SizedBox(
                      height: Utility.dynamicWidthPixel(20),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),
    );
  }
}
 */