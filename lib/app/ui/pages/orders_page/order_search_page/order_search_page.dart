import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/order_search_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/custom_dialog.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:intl/intl.dart';

class OrderSearchPage extends StatelessWidget {
  const OrderSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSearchController>(
      init: OrderSearchController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SelectableText(
              'Sipariş Numarasına Göre Ara',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(controller),
            const SizedBox(height: 16),
            Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.hasSearched && controller.foundOrders.isEmpty
                        ? Center(
                            child: SelectableText(
                              'Siparişler bulunamadı',
                              style: TextStyle(
                                fontSize: 16,
                                color: ColorManager.instance.darkGray,
                              ),
                            ),
                          )
                        : controller.selectedOrder != null
                            ? _buildOrderDetails(context, controller)
                            : controller.foundOrders.isNotEmpty
                                ? _buildOrdersList(controller)
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  )),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(OrderSearchController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchController,
            /*  onChanged: (value) {
              if (value.length >= 2) {
                controller.searchOrder(value);
              } else if (value.isEmpty) {
                controller.clearSearch();
              }
            }, */
            decoration: InputDecoration(
              hintText: 'Sipariş numarası girin (tam veya kısmi)',
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
            controller.searchOrder(controller.searchController.text.trim());
          },
          width: 80,
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

  Widget _buildOrdersList(OrderSearchController controller) {
    return ListView.builder(
      itemCount: controller.foundOrders.length,
      itemBuilder: (context, index) {
        final order = controller.foundOrders[index];
        final packageStatus = order['packageStatus'] as String? ?? 'Belirsiz';
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
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: Container(
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
                  title: InkWell(
                    onTap: () {
                      if (order['orderId'] != null) {
                        Clipboard.setData(
                            ClipboardData(text: order['orderId'].toString()));
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
                          'Sipariş #${order['orderId']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.copy, size: 16, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        _buildStatusBadge(packageStatus, statusColor),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey.shade400),
                  onTap: () {
                    controller.selectOrder(order);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetails(
      BuildContext context, OrderSearchController controller) {
    final order = controller.selectedOrder!;
    final packageStatus = order['packageStatus'] as String? ?? 'Belirsiz';
    final statusColor = _getStatusColor(packageStatus);
    // final bool isActive = order['orderSource'] == 'active';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.selectedOrder = null;
                  controller.update();
                },
              ),
              InkWell(
                onTap: () {
                  controller.selectedOrder = null;
                  controller.update();
                },
                child: const Text(
                  'Sipariş Detayları',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
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
                    top: BorderSide(color: statusColor, width: 6),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_shipping_outlined,
                            color: statusColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (order['orderId'] != null) {
                                    Clipboard.setData(ClipboardData(
                                        text: order['orderId'].toString()));
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
                                      'Sipariş #${order['orderId']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.copy,
                                        size: 18, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(order['gonderiTarihi'] ?? '-'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(packageStatus, statusColor),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('📦 Sipariş Detayları'),
                    const SizedBox(height: 16),
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
                                  value: order['vehicle']),
                              _buildDetailRow(
                                  icon: Icons.fitness_center,
                                  title: 'Ağırlık',
                                  value: order['kg']),
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
                                  value: order['content']),
                              _buildDetailRow(
                                  icon: Icons.attach_money,
                                  title: 'Fiyat',
                                  value: order['price'] != null
                                      ? '₺${order["price"]}'
                                      : '-'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('📍 Teslimat Bilgileri'),
                    const SizedBox(height: 16),
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
                            order['gonderenIsimSoyisim'],
                            '${order['il']}/${order['ilce']}',
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
                            order['aliciIsimSoyisim'],
                            '${order['aliciIl']}/${order['aliciIlce']}',
                            Icons.inbox,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('👤 Kişisel Bilgiler'),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  icon: Icons.person,
                                  title: 'Alıcı Adı',
                                  value: order['aliciIsimSoyisim']),
                              _buildDetailRow(
                                  icon: Icons.phone,
                                  title: 'Alıcı Tel',
                                  value: order['aliciPhone']),
                              _buildDetailRow(
                                  icon: Icons.credit_card,
                                  title: 'Alıcı TC',
                                  value: order['aliciKimlikNo']),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  icon: Icons.person_outline,
                                  title: 'Gönderici Adı',
                                  value: order['gonderenIsimSoyisim']),
                              _buildDetailRow(
                                  icon: Icons.phone,
                                  title: 'Gönderici Tel',
                                  value: order['phone']),
                              _buildDetailRow(
                                  icon: Icons.credit_card,
                                  title: 'Gönderici TC',
                                  value: order['gonderenKimlikNo']),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (order['kuryeIsimSoyisim'] != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionHeader('🛵 Kurye Bilgileri'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _buildDetailRow(
                                  icon: Icons.person,
                                  title: 'Kurye',
                                  value: order['kuryeIsimSoyisim'])),
                          Expanded(
                              child: _buildDetailRow(
                                  icon: Icons.phone,
                                  title: 'Telefon',
                                  value: order['kuryePhone'])),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        KargoButton(
                          text: 'Siparişi Sil',
                          textStyle: const TextStyle(fontSize: 12),
                          buttonColor: Colors.red,
                          onTap: () {
                            _showDeleteOrderDialog(controller, order);
                          },
                          width: 120,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
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

  /*void _showCompleteOrderDialog(OrderSearchController controller, Map<String, dynamic> order) {
    Get.dialog(
      AlertDialog(
        title: const SelectableText('Siparişi Tamamla'),
        content: const SelectableText('Bu sipariş "Gönderi Teslim Edildi" statüsüne geçirilecek. Onaylıyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.markOrderAsCompleted(
                order['userId'],
                order['orderId'],
                order,
              );
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  } */

  void _showDeleteOrderDialog(
      OrderSearchController controller, Map<String, dynamic> order) {
    CustomDialog.showError(
      title: 'Siparişi Sil',
      message:
          'Bu siparişi silmek istediğinizden emin misiniz?\n\n⚠️ Bu işlem geri alınamaz.',
      onConfirm: () {
        controller.deleteOrder(
          order['userId'],
          order['orderId'],
          order['packageStatus'],
        );
      },
    );
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
