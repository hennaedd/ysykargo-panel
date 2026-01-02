import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/custom_dialog.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class UserDetailModal extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onUserUpdated;

  const UserDetailModal({super.key, required this.user, this.onUserUpdated});

  @override
  State<UserDetailModal> createState() => _UserDetailModalState();
}

class _UserDetailModalState extends State<UserDetailModal> {
  List<Map<String, dynamic>> userShipments = [];
  bool isLoadingShipments = false;

  @override
  void initState() {
    super.initState();
    _loadUserShipments();
  }

  Future<void> _loadUserShipments() async {
    setState(() => isLoadingShipments = true);

    try {
      final uid = widget.user['uid'] as String;
      final userType = widget.user['user_type'] as String?;

      // Gönderileri yükle
      final shipmentsRef = FirebaseDatabase.instance.ref().child('gönderiler');
      final snapshot = await shipmentsRef.get();

      userShipments.clear();

      if (snapshot.exists) {
        final shipmentsData = snapshot.value as Map?;
        if (shipmentsData != null) {
          shipmentsData.forEach((userId, shipments) {
            if (shipments is Map) {
              shipments.forEach((orderId, shipmentDetails) {
                if (shipmentDetails is Map) {
                  // Kurye ise kuryeye atanmış gönderileri göster
                  // Müşteri ise kendi gönderilerini göster
                  if (userType == 'Kurye') {
                    final kuryeUid = shipmentDetails['kuryeUid'] as String?;
                    if (kuryeUid == uid) {
                      final order = Map<String, dynamic>.from(shipmentDetails);
                      order['orderId'] = orderId;
                      order['userId'] = userId;
                      userShipments.add(order);
                    }
                  } else {
                    if (userId == uid) {
                      final order = Map<String, dynamic>.from(shipmentDetails);
                      order['orderId'] = orderId;
                      order['userId'] = userId;
                      userShipments.add(order);
                    }
                  }
                }
              });
            }
          });
        }
      }
    } catch (e) {
      print('Gönderiler yüklenirken hata: $e');
    }

    setState(() => isLoadingShipments = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userType = user['user_type'] as String? ?? 'Müşteri';
    final accountStatus = user['account_status'] as String? ?? 'approved';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorManager.instance.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      userType == 'Kurye'
                          ? Icons.delivery_dining
                          : Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user['name'] ?? ''} ${user['surname'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                userType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  accountStatus,
                                ).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(accountStatus),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcı Bilgileri
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoSection('Kişisel Bilgiler', [
                            _buildInfoItem(
                              Icons.email,
                              'E-posta',
                              user['email'] ?? '-',
                            ),
                            _buildInfoItem(
                              Icons.phone,
                              'Telefon',
                              user['phone'] ?? '-',
                            ),
                            _buildInfoItem(
                              Icons.fingerprint,
                              'UID',
                              user['uid'] ?? '-',
                            ),
                          ]),
                        ),
                        const SizedBox(width: 24),
                        if (userType == 'Kurye')
                          Expanded(
                            child: _buildInfoSection('Kurye Bilgileri', [
                              _buildInfoItem(
                                Icons.directions_car,
                                'Araç Tipi',
                                user['vehicle_type'] ?? '-',
                              ),
                              _buildInfoItem(
                                Icons.verified,
                                'Belge Durumu',
                                user['documents_uploaded'] == true
                                    ? 'Yüklendi'
                                    : 'Yüklenmedi',
                              ),
                              _buildInfoItem(
                                Icons.calendar_today,
                                'Belge Tarihi',
                                _formatDate(user['documents_upload_date']),
                              ),
                            ]),
                          ),
                      ],
                    ),

                    // Kurye Belgeleri
                    if (userType == 'Kurye' &&
                        user['documents_uploaded'] == true) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Yüklenen Belgeler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildDocButton(
                            'Kimlik',
                            Icons.credit_card,
                            user['kimlik_foto_url'],
                          ),
                          const SizedBox(width: 12),
                          _buildDocButton(
                            'Ehliyet',
                            Icons.car_rental,
                            user['ehliyet_foto_url'],
                          ),
                          const SizedBox(width: 12),
                          _buildDocButton(
                            'Sabıka Kaydı',
                            Icons.description,
                            user['sabika_kaydi_url'],
                          ),
                        ],
                      ),
                    ],

                    // Gönderiler
                    const SizedBox(height: 24),
                    Text(
                      userType == 'Kurye' ? 'Atanan Gönderiler' : 'Gönderileri',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isLoadingShipments)
                      const Center(child: CircularProgressIndicator())
                    else if (userShipments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Gönderi bulunamadı',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...userShipments
                          .take(5)
                          .map((shipment) => _buildShipmentCard(shipment)),

                    if (userShipments.length > 5)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Tüm gönderileri göster
                          },
                          child: Text(
                            '+${userShipments.length - 5} gönderi daha',
                            style: TextStyle(
                              color: ColorManager.instance.orange,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (accountStatus == 'banned')
                    KargoButton(
                      text: 'Banı Kaldır',
                      buttonColor: Colors.green,
                      width: 130,
                      onTap: () => _showUnbanConfirmation(),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    KargoButton(
                      text: 'Banla',
                      buttonColor: Colors.red.shade900,
                      width: 100,
                      onTap: () => _showBanDialog(),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 12),
                  KargoButton(
                    text: 'Kullanıcıyı Sil',
                    buttonColor: Colors.grey.shade700,
                    width: 140,
                    onTap: () => _showDeleteConfirmation(),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorManager.instance.darkGray),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: ColorManager.instance.darkGray,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocButton(String title, IconData icon, String? url) {
    final hasDoc = url != null && url.isNotEmpty;
    return Expanded(
      child: InkWell(
        onTap: hasDoc ? () => _showDocument(title, url) : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasDoc
                ? ColorManager.instance.orange.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  hasDoc ? ColorManager.instance.orange : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: hasDoc ? ColorManager.instance.orange : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: hasDoc ? ColorManager.instance.orange : Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    final status = shipment['packageStatus'] as String? ?? 'Aktif';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getOrderStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getOrderStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getOrderStatusColor(status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_shipping,
              color: _getOrderStatusTextColor(status),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shipment['orderId'] ?? '-',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${shipment['aliciIsimSoyisim'] ?? '-'} - ${shipment['aliciIl'] ?? ''}/${shipment['aliciIlce'] ?? ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColorManager.instance.darkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getOrderStatusColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _getOrderStatusTextColor(status),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'banned':
        return Colors.red.shade900;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'approved':
        return 'Onaylı';
      case 'rejected':
        return 'Reddedildi';
      case 'banned':
        return 'Banlı';
      case 'pending':
      default:
        return 'Onay Bekliyor';
    }
  }

  Color _getOrderStatusColor(String status) {
    if (status == 'Gönderi Teslim Edildi') {
      return ColorManager.instance.statusDelivered;
    } else if (status == 'Kuryeye Atandı' || status.contains('Teslim')) {
      return ColorManager.instance.statusAssigned;
    } else {
      return ColorManager.instance.statusActive;
    }
  }

  Color _getOrderStatusTextColor(String status) {
    if (status == 'Kuryeye Atandı' || status.contains('Teslim Alındı')) {
      return Colors.black;
    }
    return Colors.white;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showDocument(String title, String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 500),
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
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, size: 48, color: Colors.red),
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

  Future<void> _unbanUser() async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(widget.user['uid'])
          .update({
        'account_status': 'approved',
        'unban_date': DateTime.now().toIso8601String(),
      });

      Get.back();
      widget.onUserUpdated?.call();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı banı kaldırıldı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Ban kaldırılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showUnbanConfirmation() {
    CustomDialog.showSuccess(
      title: 'Banı Kaldır',
      message: 'Kullanıcının banını kaldırmak istediğinize emin misiniz?',
      onConfirm: () {
        _unbanUser();
      },
    );
  }

  void _showBanDialog() {
    final reasonController = TextEditingController();
    CustomDialog.showInput(
      title: 'Kullanıcı Banla',
      message: 'Ban gerekçesini yazın:',
      content: DialogTextField(
        controller: reasonController,
        hintText: 'Gerekçe...',
        maxLines: 3,
      ),
      confirmText: 'Banla',
      onConfirm: () {
        _banUser(reasonController.text);
      },
    );
  }

  Future<void> _banUser(String reason) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(widget.user['uid'])
          .update({
        'account_status': 'banned',
        'ban_reason': reason,
        'ban_date': DateTime.now().toIso8601String(),
      });

      Get.back();
      widget.onUserUpdated?.call();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı banlandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kullanıcı banlanırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showDeleteConfirmation() {
    CustomDialog.showError(
      title: 'Kullanıcı Sil',
      message:
          'Bu kullanıcıyı silmek istediğinizden emin misiniz?\n\n⚠️ Bu işlem geri alınamaz.',
      onConfirm: () {
        _deleteUser();
      },
    );
  }

  Future<void> _deleteUser() async {
    try {
      // Aktif gönderi kontrolü
      if (widget.user['user_type'] == 'Kurye') {
        bool hasActiveShipments = false;
        final shipmentsRef = FirebaseDatabase.instance.ref().child(
              'gönderiler',
            );
        final snapshot = await shipmentsRef.get();

        if (snapshot.exists) {
          final data = snapshot.value as Map?;
          data?.forEach((userId, shipments) {
            if (shipments is Map) {
              shipments.forEach((orderId, details) {
                if (details is Map) {
                  final kuryeUid = details['kuryeUid'] as String?;
                  final status = details['packageStatus'] as String?;
                  if (kuryeUid == widget.user['uid'] &&
                      status != 'Gönderi Teslim Edildi') {
                    hasActiveShipments = true;
                  }
                }
              });
            }
          });
        }

        if (hasActiveShipments) {
          Get.snackbar(
            'Uyarı',
            'Bu kuryenin aktif gönderisi var. Önce gönderileri başka kuryeye atayın.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }

      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(widget.user['uid'])
          .remove();
      Get.back();
      widget.onUserUpdated?.call();

      Get.snackbar(
        'Başarılı',
        'Kullanıcı silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Hata',
        'Kullanıcı silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// Helper function to show user detail modal
void showUserDetailModal(
  Map<String, dynamic> user, {
  VoidCallback? onUserUpdated,
}) {
  Get.dialog(
    UserDetailModal(user: user, onUserUpdated: onUserUpdated),
    barrierDismissible: true,
  );
}
