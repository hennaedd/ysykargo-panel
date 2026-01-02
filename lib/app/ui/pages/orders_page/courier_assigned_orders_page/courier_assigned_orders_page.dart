import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/courier_assigned_orders_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';
import 'package:intl/intl.dart';

class CourierAssignedOrdersPage extends StatelessWidget {
  const CourierAssignedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourierAssignedOrdersController>(
      init: CourierAssignedOrdersController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SelectableText(
                'Kuryeye Atanmış Siparişler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(controller),
              const SizedBox(height: 16),
              controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.filteredOrders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              SelectableText(
                                'Kuryeye atanmış sipariş bulunamadı.',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : _buildOrdersList(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(CourierAssignedOrdersController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText:
                  'Sipariş ara (sipariş no, içerik, kurye, alıcı bilgileri...)',
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
          text: 'Temizle',
          textStyle: const TextStyle(fontSize: 12),
          buttonColor: ColorManager.instance.light_gray,
          onTap: () => controller.clearSearch(),
          width: 100,
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => controller.loadCourierAssignedOrders(),
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
          tooltip: 'Siparişleri Yenile',
        ),
      ],
    );
  }

  Widget _buildOrdersList(CourierAssignedOrdersController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = controller.filteredOrders[index];
        final packageStatus = order['packageStatus'] as String;
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
                          Icons.inventory_2_outlined,
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
                              _formatDate(order['gonderiTarihi'] ?? '-'),
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
                        _buildInfoChip(
                          Icons.person,
                          order['kuryeIsimSoyisim'] ?? 'Kurye Yok',
                        ),
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
    if (status.contains('Teslim Edildi')) return Colors.green;
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
