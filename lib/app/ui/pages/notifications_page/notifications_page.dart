import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ysy_kargo_panel/app/controllers/notifications_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/custom_dialog.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: NotificationsController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectableText(
                'Bildirim Gönder',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                'Tüm kullanıcılara veya belirli uygulama kullanıcılarına bildirim gönderin.',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.instance.darkGray,
                ),
              ),
              const SizedBox(height: 24),

              // Bildirim Formu
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hedef Seçimi
                    Row(
                      children: [
                        const Icon(Icons.people, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Hedef Kitle:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        _buildAppTypeChip(
                          controller,
                          'Tümü',
                          Icons.all_inclusive,
                        ),
                        const SizedBox(width: 8),
                        _buildAppTypeChip(controller, 'Müşteri', Icons.person),
                        const SizedBox(width: 8),
                        _buildAppTypeChip(
                          controller,
                          'Kurye',
                          Icons.delivery_dining,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Bildirim Başlığı
                    const Text(
                      'Bildirim Başlığı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.titleController,
                      decoration: InputDecoration(
                        hintText: 'Örn: Yeni Kampanya!',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: ColorManager.instance.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bildirim İçeriği
                    const Text(
                      'Bildirim İçeriği',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Bildirim mesajınızı buraya yazın...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.message),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: ColorManager.instance.orange,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gönder Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        controller.isLoading
                            ? const CircularProgressIndicator()
                            : KargoButton(
                                text: 'Bildirim Gönder',
                                buttonColor: ColorManager.instance.orange,
                                onTap: controller.sendNotification,
                                width: 180,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bildirim Geçmişi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SelectableText(
                    'Gönderilmiş Bildirimler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: controller.loadNotificationHistory,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorManager.instance.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: ColorManager.instance.white,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Yenile',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              controller.notificationHistory.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Henüz bildirim gönderilmemiş',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.notificationHistory.length,
                      itemBuilder: (context, index) {
                        final notification =
                            controller.notificationHistory[index];
                        return _buildNotificationHistoryCard(
                          notification,
                          controller,
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppTypeChip(
    NotificationsController controller,
    String type,
    IconData icon,
  ) {
    final isSelected = controller.selectedAppType == type;
    return InkWell(
      onTap: () => controller.changeAppType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? ColorManager.instance.orange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorManager.instance.orange
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationHistoryCard(
    Map<String, dynamic> notification,
    NotificationsController controller,
  ) {
    final timestamp = notification['timestamp'];
    String dateStr = '-';
    if (timestamp != null) {
      try {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
      } catch (e) {
        dateStr = '-';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorManager.instance.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications,
              color: ColorManager.instance.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTargetColor(notification['targetType']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification['targetType'] ?? 'Tümü',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification['body'] ?? '-',
                  style: TextStyle(
                    color: ColorManager.instance.darkGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notification['recipientCount'] ?? 0} kişi',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(
                        notification['id'],
                        controller,
                      ),
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'Sil',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTargetColor(String? target) {
    switch (target) {
      case 'Müşteri':
        return Colors.green;
      case 'Kurye':
        return Colors.blue;
      default:
        return ColorManager.instance.orange;
    }
  }

  void _showDeleteConfirmation(
    String notificationId,
    NotificationsController controller,
  ) {
    Get.dialog(
      CustomDialog(
        title: 'Bildirimi Sil',
        message:
            'Bu bildirimi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        type: DialogType.error,
        confirmText: 'Sil',
        showCancel: true,
        onConfirm: () {
          controller.deleteNotification(notificationId);
        },
      ),
    );
  }
}
