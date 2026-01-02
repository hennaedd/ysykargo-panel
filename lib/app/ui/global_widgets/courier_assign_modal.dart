import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class CourierAssignModal extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onAssigned;

  const CourierAssignModal({super.key, required this.order, this.onAssigned});

  @override
  State<CourierAssignModal> createState() => _CourierAssignModalState();
}

class _CourierAssignModalState extends State<CourierAssignModal> {
  List<Map<String, dynamic>> couriers = [];
  List<Map<String, dynamic>> filteredCouriers = [];
  bool isLoading = true;
  String? selectedCourierId;
  String searchText = '';

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCouriers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCouriers() async {
    setState(() => isLoading = true);

    try {
      final usersRef = FirebaseDatabase.instance.ref().child('users');
      final snapshot = await usersRef.get();

      couriers.clear();

      if (snapshot.exists) {
        final usersData = snapshot.value as Map?;
        if (usersData != null) {
          usersData.forEach((key, value) {
            if (value is Map) {
              final userType = value['user_type'] as String?;
              final accountStatus = value['account_status'] as String?;

              // Sadece onaylı kuryeler
              if (userType == 'Kurye' && accountStatus == 'approved') {
                final courier = Map<String, dynamic>.from(value);
                courier['uid'] = key;
                couriers.add(courier);
              }
            }
          });
        }
      }

      filteredCouriers = List.from(couriers);
    } catch (e) {
      print('Kuryeler yüklenirken hata: $e');
    }

    setState(() => isLoading = false);
  }

  void _filterCouriers(String query) {
    setState(() {
      searchText = query.toLowerCase();
      if (searchText.isEmpty) {
        filteredCouriers = List.from(couriers);
      } else {
        filteredCouriers = couriers.where((courier) {
          final name = '${courier['name'] ?? ''} ${courier['surname'] ?? ''}'
              .toLowerCase();
          final phone = (courier['phone'] ?? '').toLowerCase();
          final vehicleType = (courier['vehicle_type'] ?? '').toLowerCase();
          return name.contains(searchText) ||
              phone.contains(searchText) ||
              vehicleType.contains(searchText);
        }).toList();
      }
    });
  }

  Future<void> _assignCourier() async {
    if (selectedCourierId == null) {
      Get.snackbar(
        'Uyarı',
        'Lütfen bir kurye seçin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final selectedCourier = couriers.firstWhere(
        (c) => c['uid'] == selectedCourierId,
      );

      final userId = widget.order['userId'] as String;
      final orderId = widget.order['orderId'] as String;

      await FirebaseDatabase.instance
          .ref()
          .child('gönderiler')
          .child(userId)
          .child(orderId)
          .update({
            'packageStatus': 'Kuryeye Atandı',
            'kuryeUid': selectedCourierId,
            'kuryeIsimSoyisim':
                '${selectedCourier['name'] ?? ''} ${selectedCourier['surname'] ?? ''}',
            'kuryePhone': selectedCourier['phone'] ?? '',
            'kurye_assignment_date': DateTime.now().toIso8601String(),
          });

      Get.back();
      widget.onAssigned?.call();

      Get.snackbar(
        'Başarılı',
        'Gönderi kuryeye atandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Kurye ataması yapılırken hata: $e');
      Get.snackbar(
        'Hata',
        'Kurye ataması yapılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
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
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kurye Ata',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sipariş: ${widget.order['orderId']}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
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

            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: _filterCouriers,
                decoration: InputDecoration(
                  hintText: 'Kurye ara (isim, telefon, araç tipi)...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Courier List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredCouriers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Uygun kurye bulunamadı',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredCouriers.length,
                      itemBuilder: (context, index) {
                        final courier = filteredCouriers[index];
                        final isSelected = courier['uid'] == selectedCourierId;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedCourierId = courier['uid'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ColorManager.instance.orange.withOpacity(
                                      0.1,
                                    )
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? ColorManager.instance.orange
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? ColorManager.instance.orange
                                      : Colors.grey.shade300,
                                  child: Icon(
                                    Icons.person,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${courier['name'] ?? ''} ${courier['surname'] ?? ''}',
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? ColorManager.instance.orange
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            courier['phone'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.directions_car,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            courier['vehicle_type'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ColorManager.instance.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer
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
                  KargoButton(
                    text: 'İptal',
                    buttonColor: Colors.grey.shade400,
                    width: 100,
                    onTap: () => Get.back(),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  KargoButton(
                    text: 'Kurye Ata',
                    buttonColor: ColorManager.instance.orange,
                    width: 120,
                    onTap: _assignCourier,
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
}

// Helper function to show courier assign modal
void showCourierAssignModal(
  Map<String, dynamic> order, {
  VoidCallback? onAssigned,
}) {
  Get.dialog(
    CourierAssignModal(order: order, onAssigned: onAssigned),
    barrierDismissible: true,
  );
}
