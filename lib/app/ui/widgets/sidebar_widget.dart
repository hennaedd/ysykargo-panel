import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/home_controller.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Container(
          width: 250,
          color: Colors.black,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/images/logo.png', width: 120),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.menuCategories.length,
                  itemBuilder: (context, index) {
                    final category = controller.menuCategories[index];
                    final mainCategory = category
                        .kategori[0]; // Since kategori is a List, we take the first item
                    final hasSubCategories = category.subKategori.isNotEmpty;
                    final isMainSelected =
                        controller.selectedIndex == index &&
                        controller.selectedSubcategory.isEmpty;

                    if (hasSubCategories) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            mainCategory,
                            style: TextStyle(
                              color: ColorManager.instance.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          leading: Icon(
                            _getIconForCategory(mainCategory),
                            color: ColorManager.instance.white,
                          ),
                          iconColor: ColorManager.instance.white,
                          collapsedIconColor: ColorManager.instance.white,
                          backgroundColor: Colors.black,
                          children: category.subKategori.map((subCategory) {
                            final isSubcategorySelected =
                                controller.selectedSubcategory == subCategory;
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 60,
                                right: 16,
                              ),
                              title: Text(
                                subCategory,
                                style: TextStyle(
                                  color: isSubcategorySelected
                                      ? ColorManager.instance.orange
                                      : ColorManager.instance.white,
                                  fontSize: 14,
                                  fontWeight: isSubcategorySelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              tileColor: isSubcategorySelected
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.transparent,
                              onTap: () {
                                controller.changeSelectedIndex(index);
                                controller.selectSubcategory(subCategory);
                              },
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return ListTile(
                        leading: Icon(
                          _getIconForCategory(mainCategory),
                          color: isMainSelected
                              ? ColorManager.instance.orange
                              : ColorManager.instance.white,
                        ),
                        title: Text(
                          mainCategory,
                          style: TextStyle(
                            color: isMainSelected
                                ? ColorManager.instance.orange
                                : ColorManager.instance.white,
                            fontWeight: isMainSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        tileColor: isMainSelected
                            ? Colors.black.withOpacity(0.8)
                            : Colors.transparent,
                        onTap: () {
                          controller.changeSelectedIndex(index);
                          controller.selectSubcategory('');
                        },
                      );
                    }
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.7),
                child: InkWell(
                  onTap: controller.logout,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ColorManager.instance.orange
                            .withOpacity(0.2),
                        radius: 25,
                        child: Icon(
                          Icons.exit_to_app,
                          color: ColorManager.instance.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Çıkış Yap',
                          style: TextStyle(
                            color: ColorManager.instance.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Anasayfa':
        return Icons.home;
      case 'Kullanıcı İşlemleri':
        return Icons.people;
      case 'Sipariş İşlemleri':
        return Icons.local_shipping;
      case 'Bildirimler':
        return Icons.notifications;
      case 'Ayarlar':
        return Icons.settings;
      default:
        return Icons.folder;
    }
  }
}
