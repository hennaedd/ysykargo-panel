import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/customer_shipments_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/custom_dialog.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class CustomerShipmentsPage extends StatelessWidget {
  const CustomerShipmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerShipmentsController>(
      init: CustomerShipmentsController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.selectedUserId != null &&
                    controller.selectedUserInfo != null
                ? _buildSelectedUserInfo(controller)
                : const SelectableText(
                    'Müşteriye Ait Gönderiler',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 16),
            controller.selectedUserId == null
                ? _buildUserSearchBar(controller)
                : _buildFilterBar(controller),
            const SizedBox(height: 16),
            controller.selectedUserId == null
                ? (controller.isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : controller.searchResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                SelectableText(
                                  'Arama sonucu bulunamadı',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : _buildUsersTable(controller))
                : Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : controller.filteredShipments.isEmpty
                            ? Center(
                                child: SelectableText(
                                  'Gönderi bulunamadı',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ColorManager.instance.darkGray,
                                  ),
                                ),
                              )
                            : _buildShipmentsList(controller),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildSelectedUserInfo(CustomerShipmentsController controller) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.clearSelectedUser();
          },
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                '${controller.selectedUserInfo!['name'] ?? ''} ${controller.selectedUserInfo!['surname'] ?? ''}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.instance.black),
              ),
              SelectableText(
                '${controller.selectedUserInfo!['email'] ?? ''} - ${controller.selectedUserInfo!['phone'] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorManager.instance.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserSearchBar(CustomerShipmentsController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.userSearchController,
            decoration: InputDecoration(
              hintText: 'Müşteri ara (isim, e-posta, telefon)',
              prefixIcon:
                  Icon(Icons.search, color: ColorManager.instance.darkGray),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorManager.instance.light_gray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorManager.instance.light_gray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorManager.instance.orange),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        KargoButton(
          text: 'Ara',
          textStyle: const TextStyle(fontSize: 12),
          buttonColor: ColorManager.instance.orange,
          onTap: () {
            controller.searchUser(controller.userSearchController.text);
          },
          width: 100,
        ),
        const SizedBox(width: 12),
        KargoButton(
          text: 'Temizle',
          textStyle: const TextStyle(fontSize: 12),
          buttonColor: ColorManager.instance.light_gray,
          onTap: () {
            controller.clearSearch();
          },
          width: 100,
        ),
      ],
    );
  }

  Widget _buildFilterBar(CustomerShipmentsController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.shipmentSearchController,
                decoration: InputDecoration(
                  hintText: 'Gönderi ara (içerik, alıcı bilgileri...)',
                  prefixIcon:
                      Icon(Icons.search, color: ColorManager.instance.darkGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: ColorManager.instance.light_gray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: ColorManager.instance.light_gray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: ColorManager.instance.orange),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            KargoButton(
              text: 'Temizle',
              textStyle: const TextStyle(fontSize: 12),
              buttonColor: ColorManager.instance.light_gray,
              onTap: () {
                controller.clearSearch();
              },
              width: 100,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KargoButton(
                text: 'Aktif Gönderiler',
                textStyle: const TextStyle(fontSize: 14),
                buttonColor: controller.viewingActiveShipments
                    ? ColorManager.instance.orange
                    : ColorManager.instance.light_gray,
                onTap: () {
                  if (controller.selectedUserId != null) {
                    controller
                        .loadCustomerShipments(controller.selectedUserId!);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KargoButton(
                text: 'Tamamlanan Gönderiler',
                textStyle: const TextStyle(fontSize: 14),
                buttonColor: !controller.viewingActiveShipments
                    ? ColorManager.instance.orange
                    : ColorManager.instance.light_gray,
                onTap: () {
                  if (controller.selectedUserId != null) {
                    controller
                        .loadCompletedShipments(controller.selectedUserId!);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersTable(CustomerShipmentsController controller) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: ColorManager.instance.light_gray),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 20,
            headingRowColor: WidgetStateColor.resolveWith(
              (states) => ColorManager.instance.softGrayBg,
            ),
            columns: const [
              DataColumn(
                  label: SelectableText('İsim Soyisim',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: SelectableText('E-posta',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: SelectableText('Telefon',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: SelectableText('İşlem',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: controller.searchResults.map<DataRow>((user) {
              final userName = '${user['name'] ?? ''} ${user['surname'] ?? ''}';
              final userEmail = user['email'] ?? '';
              final userPhone = user['phone'] ?? '';

              return DataRow(
                cells: [
                  DataCell(SelectableText(userName)),
                  DataCell(SelectableText(userEmail)),
                  DataCell(SelectableText(userPhone)),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: KargoButton(
                        text: 'Gönderileri Listele',
                        textStyle: const TextStyle(fontSize: 12),
                        buttonColor: ColorManager.instance.orange,
                        onTap: () {
                          controller.selectUser(user);
                        },
                        width: 150,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentsList(CustomerShipmentsController controller) {
    return ListView.builder(
      itemCount: controller.filteredShipments.length,
      itemBuilder: (context, index) {
        final shipment = controller.filteredShipments[index];
        final packageStatus =
            shipment['packageStatus'] as String? ?? 'Bekleniyor';
        final statusColor = _getStatusColor(packageStatus);

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: statusColor, width: 6),
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: Colors.transparent,
                  collapsedBackgroundColor: Colors.transparent,
                  tilePadding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                  childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping_outlined,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                if (shipment['orderId'] != null) {
                                  Clipboard.setData(ClipboardData(
                                      text: shipment['orderId'].toString()));
                                  Get.snackbar(
                                    'Kopyalandı',
                                    'Sipariş numarası kopyalandı',
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.black87,
                                    colorText: Colors.white,
                                    margin: const EdgeInsets.all(10),
                                    borderRadius: 10,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Sipariş #${shipment['orderId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.copy,
                                      size: 16, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(shipment['gonderiTarihi'] ?? '-'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        if (shipment['kuryeIsimSoyisim'] != null)
                          _buildInfoChip(
                            Icons.person,
                            shipment['kuryeIsimSoyisim'],
                          ),
                        if (shipment['kuryeIsimSoyisim'] != null)
                          const SizedBox(width: 12),
                        _buildStatusBadge(packageStatus, statusColor),
                      ],
                    ),
                  ),
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSectionHeader('📦 Sipariş Detayları'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  icon: Icons.directions_car,
                                  title: 'Taşıt',
                                  value: shipment['vehicle']),
                              _buildDetailRow(
                                  icon: Icons.fitness_center,
                                  title: 'Ağırlık',
                                  value: shipment['kg']),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  icon: Icons.description,
                                  title: 'İçerik',
                                  value: shipment['content']),
                              _buildDetailRow(
                                  icon: Icons.attach_money,
                                  title: 'Fiyat',
                                  value: shipment['price'] != null
                                      ? '₺${shipment["price"]}'
                                      : '-'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionHeader('📍 Teslimat Bilgileri'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildRouteRow(
                            'Gönderici',
                            shipment['gonderenIsimSoyisim'],
                            '${shipment['il']}/${shipment['ilce']}',
                            Icons.outbound,
                            Colors.orange,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 2,
                                  color: Colors.grey.shade300,
                                  margin: const EdgeInsets.only(left: 11),
                                ),
                              ],
                            ),
                          ),
                          _buildRouteRow(
                            'Alıcı',
                            shipment['aliciIsimSoyisim'],
                            '${shipment['aliciIl']}/${shipment['aliciIlce']}',
                            Icons.inbox,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (controller.viewingActiveShipments) ...[
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          KargoButton(
                            text: 'Siparişi Sil',
                            textStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            buttonColor: Colors.red,
                            onTap: () {
                              _showDeleteOrderDialog(
                                  context, controller, shipment);
                            },
                            width: 120,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColorManager.instance.darkGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRouteRow(
    String label,
    String? name,
    String location,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                name ?? '-',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('Teslim Edildi') || status.contains('Tamamlandı'))
      return Colors.green;
    if (status.contains('İptal') || status.contains('Başarısız'))
      return Colors.red;
    if (status.contains('Kuryeye Atandı') ||
        status.contains('Yolda') ||
        status.contains('Dağıtımda')) return Colors.blue;
    return ColorManager.instance.orange;
  }

  Widget _buildDetailRow(
      {required IconData icon, required String title, required String? value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value ?? '-',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteOrderDialog(BuildContext context,
      CustomerShipmentsController controller, Map<String, dynamic> shipment) {
    CustomDialog.showError(
      title: 'Siparişi Sil',
      message:
          'Bu siparişi silmek istediğinizden emin misiniz?\n\n⚠️ Bu işlem geri alınamaz.',
      onConfirm: () {
        _deleteOrder(controller, shipment);
      },
    );
  }

  void _deleteOrder(CustomerShipmentsController controller,
      Map<String, dynamic> shipment) async {
    final userId = controller.selectedUserId!;
    final orderId = shipment['orderId'] as String;

    try {
      if (controller.viewingActiveShipments) {
        await FirebaseDatabase.instance
            .ref()
            .child('gönderiler')
            .child(userId)
            .child(orderId)
            .remove();
        controller.loadCustomerShipments(userId);
      } else {
        await FirebaseDatabase.instance
            .ref()
            .child('tamamlanan_siparisler')
            .child(userId)
            .child(orderId)
            .remove();
        controller.loadCompletedShipments(userId);
      }

      Get.snackbar(
        'Başarılı',
        'Sipariş silindi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Sipariş silinirken hata oluştu: $e');
      Get.snackbar(
        'Hata',
        'Sipariş silinirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr == '-') return '-';
    try {
      // Mevcut tarih formatını belirlemeye çalış
      DateTime? date;
      if (dateStr.contains('/')) {
        // Zaten "/" içeren bir format
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          date = DateTime(
            int.parse(parts[2]), // yıl
            int.parse(parts[1]), // ay
            int.parse(parts[0]), // gün
          );
        }
      } else if (dateStr.contains('-')) {
        // "-" içeren bir format (örn. yyyy-MM-dd)
        date = DateTime.parse(dateStr);
      } else if (dateStr.length == 8) {
        // YYYYMMDD formatı
        date = DateTime(
          int.parse(dateStr.substring(0, 4)), // yıl
          int.parse(dateStr.substring(4, 6)), // ay
          int.parse(dateStr.substring(6, 8)), // gün
        );
      } else {
        // Milisaniye cinsinden timestamp (Unix epoch)
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
      }

      if (date != null) {
        // DD/MM/YYYY formatına dönüştür
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return dateStr; // Dönüştürülemezse orijinal değeri döndür
    } catch (e) {
      print('Tarih çevirme hatası: $e, Orijinal değer: $dateStr');
      return dateStr; // Hata durumunda orijinal değeri döndür
    }
  }
}
