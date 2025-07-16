import 'package:flutter/material.dart';

class CuteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? leftButtonText;
  final String? rightButtonText;
  final VoidCallback? onLeftButtonPressed;
  final VoidCallback? onRightButtonPressed;
  final bool showCloseButton;

  const CuteDialog({
    super.key,
    required this.title,
    required this.content,
    this.leftButtonText,
    this.rightButtonText,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.8; // 限制为屏幕宽度的80%
    final maxWidth = 400.0; // 最大宽度限制
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth > maxWidth ? maxWidth : dialogWidth,
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
          minHeight: 200,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 可爱的头部装饰
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // 可爱的装饰图标
                  Positioned(
                    left: 20,
                    top: 15,
                    child: Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  // 标题
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // 关闭按钮
                  if (showCloseButton)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 按钮区域
            if (leftButtonText != null || rightButtonText != null)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (leftButtonText != null)
                      Expanded(
                        child: _buildButton(
                          text: leftButtonText!,
                          onPressed: onLeftButtonPressed ?? () => Navigator.of(context).pop(),
                          isPrimary: false,
                        ),
                      ),
                    if (leftButtonText != null && rightButtonText != null)
                      const SizedBox(width: 12),
                    if (rightButtonText != null)
                      Expanded(
                        child: _buildButton(
                          text: rightButtonText!,
                          onPressed: onRightButtonPressed ?? () => Navigator.of(context).pop(),
                          isPrimary: true,
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

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.pinkAccent : Colors.white.withOpacity(0.3),
          foregroundColor: isPrimary ? Colors.white : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: isPrimary ? 5 : 2,
          shadowColor: isPrimary ? Colors.pinkAccent.withOpacity(0.5) : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isPrimary ? Colors.white : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// 便捷的显示方法
class CuteDialogHelper {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String? leftButtonText,
    String? rightButtonText,
    VoidCallback? onLeftButtonPressed,
    VoidCallback? onRightButtonPressed,
    bool showCloseButton = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CuteDialog(
        title: title,
        content: content,
        leftButtonText: leftButtonText,
        rightButtonText: rightButtonText,
        onLeftButtonPressed: onLeftButtonPressed,
        onRightButtonPressed: onRightButtonPressed,
        showCloseButton: showCloseButton,
      ),
    );
  }
}
