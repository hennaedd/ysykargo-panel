import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/users_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/user_detail_modal.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(
      init: UsersController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      dropdownColor: ColorManager.instance.white,
                      value: controller.userTypeFilter,
                      underline: const SizedBox(),
                      items: ['Tümü', 'Müşteri', 'Kurye']
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: SelectableText(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.changeUserTypeFilter(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => controller.loadUsers(),
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorManager.instance.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: ColorManager.instance.white,
                        size: 24,
                      ),
                    ),
                    tooltip: 'Kullanıcıları Yenile',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Kullanıcı listesi
              Container(
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredUsers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                SelectableText(
                                  'Kullanıcı bulunamadı',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildUserList(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(UsersController controller) {
    return Column(
      children: [
        Container(
          color: ColorManager.instance.orange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: SelectableText(
                  'İsim Soyisim',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SelectableText(
                  'E-posta',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SelectableText(
                  'Telefon',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SelectableText(
                  'Kullanıcı Tipi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SelectableText(
                  'Araç Tipi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scrollable Data Area
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(controller.filteredUsers.length, (index) {
                final user = controller.filteredUsers[index];
                final rowColor =
                    index % 2 == 0 ? Colors.white : Colors.grey.shade50;
                final accountStatus =
                    user['account_status'] as String? ?? 'approved';

                return InkWell(
                  onTap: () => showUserDetailModal(
                    user,
                    onUserUpdated: controller.loadUsers,
                  ),
                  child: Container(
                    color: rowColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              // Status indicator
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _getAccountStatusColor(accountStatus),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${user['name'] ?? ''} ${user['surname'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            user['email'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(user['phone'] ?? ''),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: user['user_type'] == 'Kurye'
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              user['user_type'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: user['user_type'] == 'Kurye'
                                    ? Colors.blue
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(user['vehicle_type'] ?? '-'),
                          ),
                        ),
                        // Action button
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 18),
                          tooltip: 'Detay',
                          onPressed: () => showUserDetailModal(
                            user,
                            onUserUpdated: controller.loadUsers,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Fixed Footer (User count area)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SelectableText(
                'Toplam ${controller.filteredUsers.length} kullanıcı',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAccountStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'banned':
        return Colors.red.shade900;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
