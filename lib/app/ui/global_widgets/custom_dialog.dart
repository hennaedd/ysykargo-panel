import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ysy_kargo_panel/app/utils/color_manager.dart';

enum DialogType { info, success, warning, error, confirm, input }

class CustomDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final DialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.type = DialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancel = true,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getHeaderGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (barrierDismissible)
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      splashRadius: 20,
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message != null)
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 15,
                        color: ColorManager.instance.darkGray,
                        height: 1.5,
                      ),
                    ),
                  if (content != null) ...[
                    if (message != null) const SizedBox(height: 16),
                    content!,
                  ],
                ],
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showCancel)
                    TextButton(
                      onPressed: () {
                        Get.back();
                        onCancel?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cancelText ?? 'İptal',
                        style: TextStyle(
                          color: ColorManager.instance.darkGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmText ?? _getDefaultConfirmText(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

  List<Color> _getHeaderGradient() {
    switch (type) {
      case DialogType.success:
        return [Colors.green.shade400, Colors.green.shade600];
      case DialogType.warning:
        return [Colors.orange.shade400, Colors.orange.shade600];
      case DialogType.error:
        return [Colors.red.shade400, Colors.red.shade600];
      case DialogType.confirm:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case DialogType.input:
        return [ColorManager.instance.orange, Colors.deepOrange];
      default:
        return [ColorManager.instance.orange, Colors.deepOrange];
    }
  }

  IconData _getIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle;
      case DialogType.warning:
        return Icons.warning_rounded;
      case DialogType.error:
        return Icons.error;
      case DialogType.confirm:
        return Icons.help_outline;
      case DialogType.input:
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  Color _getButtonColor() {
    switch (type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return Colors.red;
      case DialogType.confirm:
        return Colors.blue;
      default:
        return ColorManager.instance.orange;
    }
  }

  String _getDefaultConfirmText() {
    switch (type) {
      case DialogType.success:
        return 'Tamam';
      case DialogType.warning:
        return 'Devam Et';
      case DialogType.error:
        return 'Tamam';
      case DialogType.confirm:
        return 'Onayla';
      case DialogType.input:
        return 'Kaydet';
      default:
        return 'Tamam';
    }
  }

  // Static helper methods
  static void showSuccess({
    required String title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        type: DialogType.success,
        showCancel: false,
        onConfirm: onConfirm,
      ),
    );
  }

  static void showError({
    required String title,
    String? message,
    VoidCallback? onConfirm,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        type: DialogType.error,
        showCancel: false,
        onConfirm: onConfirm,
      ),
    );
  }

  static void showWarning({
    required String title,
    String? message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        type: DialogType.warning,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static void showConfirm({
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        type: DialogType.confirm,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static void showInput({
    required String title,
    String? message,
    required Widget content,
    String? confirmText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      CustomDialog(
        title: title,
        message: message,
        content: content,
        type: DialogType.input,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        barrierDismissible: false,
      ),
      barrierDismissible: false,
    );
  }
}

// Modern TextField for dialogs
class DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final bool obscureText;
  final IconData? prefixIcon;

  const DialogTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: ColorManager.instance.orange)
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.instance.orange, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
