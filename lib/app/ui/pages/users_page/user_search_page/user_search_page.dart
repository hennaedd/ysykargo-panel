import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/controllers/user_search_controller.dart';
import 'package:ysy_kargo_panel/app/ui/global_widgets/button.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

class UserSearchPage extends StatelessWidget {
  final String initialSearchType;

  const UserSearchPage({
    super.key,
    this.initialSearchType = 'Tümü',
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserSearchController>(
      init: UserSearchController(),
      builder: (controller) {
        if (controller.searchType != initialSearchType) {
          controller.changeSearchType(initialSearchType);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller),
              const SizedBox(height: 12),
              _buildSearchForm(controller),
              const SizedBox(height: 24),
              _buildSearchResults(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserSearchController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: controller.loadAllUsers,
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
    );
  }

  Widget _buildSearchForm(UserSearchController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelectableText(
            'Arama Filtreleri',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('İsim', 'name', controller)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Soyisim', 'surname', controller)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('E-posta', 'email', controller)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Telefon', 'phone', controller)),
            ],
          ),
          if (controller.searchType == 'Kurye') ...[
            const SizedBox(height: 16),
            _buildTextField('Araç Tipi', 'vehicle_type', controller),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KargoButton(
                text: 'Temizle',
                buttonColor: Colors.grey,
                width: 120,
                textStyle: const TextStyle(fontSize: 12),
                onTap: controller.clearFilters,
              ),
              const SizedBox(width: 16),
              KargoButton(
                text: 'Ara',
                buttonColor: ColorManager.instance.orange,
                width: 120,
                textStyle: const TextStyle(fontSize: 12),
                onTap: controller.searchUsers,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String filterKey, UserSearchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller.textControllers[filterKey], // Use controller from UserSearchController
          decoration: InputDecoration(
            hintText: '$label giriniz',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => controller.updateSearchFilter(filterKey, value),
        ),
      ],
    );
  }

  Widget _buildSearchResults(UserSearchController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            SelectableText(
              'Arama sonucu bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
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
      child: Column(
        children: [
          _buildTableHeader(controller),
          _buildTableBody(controller),
          _buildTableFooter(controller),
        ],
      ),
    );
  }

  Widget _buildTableHeader(UserSearchController controller) {
    return Container(
      color: ColorManager.instance.orange,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SelectableText('İsim Soyisim', style: _headerTextStyle)),
          const Expanded(flex: 2, child: SelectableText('E-posta', style: _headerTextStyle)),
          const Expanded(flex: 1, child: SelectableText('Telefon', style: _headerTextStyle)),
          const Expanded(flex: 1, child: SelectableText('Kullanıcı Tipi', style: _headerTextStyle)),
          if (controller.searchType == 'Tümü' || controller.searchType == 'Kurye')
            const Expanded(flex: 1, child: SelectableText('Araç Tipi', style: _headerTextStyle)),
        ],
      ),
    );
  }

  Widget _buildTableBody(UserSearchController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = controller.searchResults[index];
        final rowColor = index % 2 == 0 ? Colors.white : Colors.grey.shade50;

        return Container(
          color: rowColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SelectableText(
                  '${user['name'] ?? ''} ${user['surname'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(flex: 2, child: SelectableText(user['email'] ?? '')),
              Expanded(flex: 1, child: SelectableText(user['phone'] ?? '')),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['user_type'] == 'Kurye' ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(
                    user['user_type'] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: user['user_type'] == 'Kurye' ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              if (controller.searchType == 'Tümü' || controller.searchType == 'Kurye')
                Expanded(flex: 1, child: SelectableText(user['vehicle_type'] ?? '-')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableFooter(UserSearchController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SelectableText('Toplam ${controller.searchResults.length} sonuç'),
        ],
      ),
    );
  }
}

const _headerTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.white,
);
