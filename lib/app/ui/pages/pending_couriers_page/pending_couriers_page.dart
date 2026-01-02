import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ysy_kargo_panel/app/controllers/pending_couriers_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/custom_dialog.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'dart:html' as html;

class PendingCouriersPage extends StatelessWidget {
  const PendingCouriersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PendingCouriersController>(
      init: PendingCouriersController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SelectableText(
                    'Kurye Belge İncelemeleri',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // Durum Filtresi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: controller.statusFilter,
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Onay Bekleyen'),
                            ),
                            DropdownMenuItem(
                              value: 'approved',
                              child: Text('Onaylı'),
                            ),
                            DropdownMenuItem(
                              value: 'rejected',
                              child: Text('Reddedilen'),
                            ),
                            DropdownMenuItem(
                              value: 'banned',
                              child: Text('Banlı'),
                            ),
                            DropdownMenuItem(value: 'all', child: Text('Tümü')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.changeStatusFilter(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: controller.loadPendingCouriers,
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
                        tooltip: 'Yenile',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                'Kuryelerin belgelerini inceleyip onaylayın veya reddedin.',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.instance.darkGray,
                ),
              ),
              const SizedBox(height: 24),
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.pendingCouriers.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Bu kategoride kurye bulunamadı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.pendingCouriers.length,
                          itemBuilder: (context, index) {
                            final courier = controller.pendingCouriers[index];
                            return _buildCourierCard(
                                courier, controller, context);
                          },
                        ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourierCard(
    Map<String, dynamic> courier,
    PendingCouriersController controller,
    BuildContext context,
  ) {
    final accountStatus = courier['account_status'] as String? ?? 'pending';
    final statusColor = controller.getStatusColor(accountStatus);
    final statusText = controller.getStatusText(accountStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.all(20),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.person, color: statusColor, size: 28),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${courier['name'] ?? ''} ${courier['surname'] ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courier['email'] ?? '-',
                      style: TextStyle(
                        color: ColorManager.instance.darkGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Bilgileri
                const Text(
                  'Kişisel Bilgiler',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'Telefon', courier['phone'] ?? '-'),
                _buildInfoRow(
                  Icons.directions_car,
                  'Araç Tipi',
                  courier['vehicle_type'] ?? '-',
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Belge Yükleme Tarihi',
                  _formatDate(courier['documents_upload_date']),
                ),

                const SizedBox(height: 24),

                // Belgeler
                const Text(
                  'Belgeler',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDocumentButton(
                        'Kimlik',
                        Icons.credit_card,
                        courier['kimlik_foto_url'],
                        context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDocumentButton(
                        'Ehliyet',
                        Icons.car_rental,
                        courier['ehliyet_foto_url'],
                        context,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDocumentButton(
                        'Sabıka Kaydı',
                        Icons.description,
                        courier['sabika_kaydi_url'],
                        context,
                      ),
                    ),
                  ],
                ),

                // Ret ya da Ban gerekçesi varsa göster
                if (courier['rejection_reason'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Red Gerekçesi: ${courier['rejection_reason']}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (courier['ban_reason'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red.shade900),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ban Gerekçesi: ${courier['ban_reason']}',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Aksiyon Butonları
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (accountStatus == 'pending') ...[
                      KargoButton(
                        text: 'Onayla',
                        buttonColor: Colors.green,
                        width: 120,
                        onTap: () => _showApproveConfirmation(
                          courier['uid'],
                          controller,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      KargoButton(
                        text: 'Reddet',
                        buttonColor: Colors.red,
                        width: 120,
                        onTap: () =>
                            _showRejectDialog(courier['uid'], controller),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (accountStatus == 'banned')
                      KargoButton(
                        text: 'Banı Kaldır',
                        buttonColor: Colors.green,
                        width: 130,
                        onTap: () =>
                            _showUnbanConfirmation(courier['uid'], controller),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (accountStatus != 'pending')
                      KargoButton(
                        text: 'Banla',
                        buttonColor: Colors.red.shade900,
                        width: 100,
                        onTap: () => _showBanDialog(courier['uid'], controller),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    KargoButton(
                      text: 'Sil',
                      buttonColor: Colors.grey.shade700,
                      width: 80,
                      onTap: () =>
                          _showDeleteConfirmation(courier['uid'], controller),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorManager.instance.darkGray),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: ColorManager.instance.darkGray),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(
    String title,
    IconData icon,
    String? url,
    BuildContext context,
  ) {
    final hasDocument = url != null && url.isNotEmpty;

    return InkWell(
      onTap:
          hasDocument ? () => _showDocumentViewer(title, url, context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: hasDocument
              ? ColorManager.instance.orange.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDocument
                ? ColorManager.instance.orange
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: hasDocument ? ColorManager.instance.orange : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: hasDocument ? ColorManager.instance.orange : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasDocument ? 'Görüntüle' : 'Yüklenmemiş',
              style: TextStyle(
                color:
                    hasDocument ? ColorManager.instance.darkGray : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentViewer(String title, String url, BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorManager.instance.orange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // URL'yi yeni sekmede aç
                            html.window.open(url, '_blank');
                          },
                          icon: const Icon(Icons.open_in_new,
                              color: Colors.white),
                          tooltip: 'Tarayıcıda Aç',
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: url.toLowerCase().endsWith('.pdf')
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text('PDF Belgesi'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                html.window.open(url, '_blank');
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Tarayıcıda Aç'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.instance.orange,
                              ),
                            ),
                          ],
                        ),
                      )
                    : InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4,
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image_not_supported,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Görsel panel içinde görüntülenemiyor',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Aşağıdaki butona tıklayarak tarayıcıda açabilirsiniz',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      html.window.open(url, '_blank');
                                    },
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Tarayıcıda Aç'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorManager.instance.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showApproveConfirmation(
    String uid,
    PendingCouriersController controller,
  ) {
    CustomDialog.showConfirm(
      title: 'Kurye Onayla',
      message:
          'Bu kuryenin başvurusunu onaylamak istediğinizden emin misiniz?\n\nOnaylandıktan sonra kurye siparişleri kabul edebilecektir.',
      confirmText: 'Onayla',
      onConfirm: () => controller.approveCourier(uid),
    );
  }

  void _showRejectDialog(String uid, PendingCouriersController controller) {
    final reasonController = TextEditingController();
    Get.dialog(
      CustomDialog(
        title: 'Kurye Reddet',
        message: 'Bu kuryenin başvurusunu reddetmek için bir gerekçe yazın.',
        type: DialogType.error,
        confirmText: 'Reddet',
        content: DialogTextField(
          controller: reasonController,
          hintText: 'Red gerekçesi...',
          maxLines: 3,
          prefixIcon: Icons.comment,
        ),
        onConfirm: () => controller.rejectCourier(uid, reasonController.text),
      ),
      barrierDismissible: false,
    );
  }

  void _showBanDialog(String uid, PendingCouriersController controller) {
    final reasonController = TextEditingController();
    Get.dialog(
      CustomDialog(
        title: 'Kullanıcı Banla',
        message:
            'Bu kullanıcıyı kalıcı olarak engellemek için bir gerekçe yazın.',
        type: DialogType.error,
        confirmText: 'Banla',
        content: DialogTextField(
          controller: reasonController,
          hintText: 'Ban gerekçesi...',
          maxLines: 3,
          prefixIcon: Icons.block,
        ),
        onConfirm: () => controller.banUser(uid, reasonController.text),
      ),
      barrierDismissible: false,
    );
  }

  void _showUnbanConfirmation(
    String uid,
    PendingCouriersController controller,
  ) {
    CustomDialog.showConfirm(
      title: 'Banı Kaldır',
      message:
          'Bu kullanıcının banını kaldırmak istediğinizden emin misiniz? Kullanıcı tekrar uygulamayı kullanabilecektir.',
      confirmText: 'Banı Kaldır',
      onConfirm: () => controller.unbanUser(uid),
    );
  }

  void _showDeleteConfirmation(
    String uid,
    PendingCouriersController controller,
  ) {
    CustomDialog.showWarning(
      title: 'Kullanıcı Sil',
      message:
          'Bu kullanıcıyı silmek istediğinizden emin misiniz?\n\n⚠️ Bu işlem geri alınamaz ve kullanıcının tüm verileri silinecektir.',
      onConfirm: () => controller.deleteUser(uid),
    );
  }
}
