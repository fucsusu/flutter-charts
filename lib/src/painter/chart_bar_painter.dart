part of 'chart_painter.dart';

/// Layer painter for bar.
class _ChartBarPainter {
  const _ChartBarPainter._();

  /// Draw bar.
  static void draw({
    required Canvas canvas,
    required AnimationController controller,
    required ChartBarLayer layer,
    required ChartPainterData painterData,
    required List<TouchableShape<ChartDataItem>> touchableShapes,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartBarLayer? oldLayer,
  }) {
    double beforeTotalHeight = 0;
    for (int i = 0; i < layer.items.length; i++) {
      final ChartBarDataItem item = layer.items[i];
      _calculate(
        controller: controller,
        item: item,
        oldItem: (oldLayer?.items)?.getOrNull(i),
        painterData: painterData,
        settings: layer.settings,
        xValue: xValue,
        yValue: yValue,
      );
      _drawBarBackground(layer, canvas, item, painterData);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          item.currentValuePos.translate(0, -beforeTotalHeight) & item.currentValueSize,
          bottomLeft: layer.settings.radius.bottomLeft,
          bottomRight: layer.settings.radius.bottomRight,
          topLeft: layer.settings.radius.topLeft,
          topRight: layer.settings.radius.topRight,
        ),
        Paint()..color = item.currentValueColor,
      );

      touchableShapes.add(RectangleShape<ChartBarDataItem>(
          dataList: [item], rectOffset: item.currentTouchPos, rectSize: item.currentTouchSize));

      beforeTotalHeight = _calculateBeforeTotalHeight(layer, beforeTotalHeight, i);
    }
  }

  ///计算数据位置
  static void _calculate({
    required AnimationController controller,
    required ChartBarDataItem item,
    required ChartPainterData painterData,
    required ChartBarSettings settings,
    required ChartAxisValue xValue,
    required ChartAxisValue yValue,
    ChartBarDataItem? oldItem,
  }) {
    final double offsetX = painterData.size.width * (item.x - xValue.min) / (xValue.max - xValue.min);
    final Size size = Size(
      settings.thickness,
      painterData.size.height * (item.value - yValue.min) / (yValue.max - yValue.min),
    );
    final Offset pos = Offset(
      painterData.position.dx + offsetX - size.width.half,
      painterData.position.dy + painterData.size.height - size.height,
    );
    item.setupValue(
      color: item.color,
      controller: controller,
      initialColor: oldItem?.lastValueColor ?? Colors.transparent,
      initialPos: oldItem?.lastValuePos ?? Offset(pos.dx, painterData.position.dy + painterData.size.height),
      initialSize: oldItem?.lastValueSize ?? Size(size.width, 0.0),
      pos: pos,
      size: size,
    );
    item.setupTouch(
      controller: controller,
      initialPos: oldItem?.lastValuePos ?? Offset(pos.dx, painterData.position.dy),
      initialSize: oldItem?.lastValueSize ?? Size(size.width, painterData.size.height),
      pos: Offset(pos.dx, painterData.position.dy),
      size: Size(size.width, painterData.size.height),
    );
  }

  ///绘制背景颜色
  static void _drawBarBackground(
    ChartBarLayer layer,
    Canvas canvas,
    ChartBarDataItem item,
    ChartPainterData painterData,
  ) {
    if (layer.settings.barBackground != null) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Offset(item.currentValuePos.dx, painterData.position.dy) & Size(layer.settings.thickness, painterData.size.height),
          bottomLeft: layer.settings.radius.bottomLeft,
          bottomRight: layer.settings.radius.bottomRight,
          topLeft: layer.settings.radius.topLeft,
          topRight: layer.settings.radius.topRight,
        ),
        Paint()..color = layer.settings.barBackground!,
      );
    }
  }

  ///计算瀑布图偏移量
  static double _calculateBeforeTotalHeight(ChartBarLayer layer, double beforeTotalHeight, int i) {
    if (layer.settings.waterfallMode) {
      if (layer.settings.direction == WaterfallBarDirection.toLeft && 0 == i) {
        beforeTotalHeight = layer.items[i].currentValueSize.height;
      } else if (layer.settings.direction == WaterfallBarDirection.toRight && layer.items.length - 2 == i) {
        beforeTotalHeight = 0;
      } else if (layer.settings.direction == WaterfallBarDirection.toRight) {
        beforeTotalHeight += layer.items[i].currentValueSize.height;
      }
      if (layer.settings.direction == WaterfallBarDirection.toLeft && i < layer.items.length - 1) {
        final ChartBarDataItem nextItem = layer.items[i + 1];
        beforeTotalHeight -= nextItem.currentValueSize.height;
      }
    }
    return beforeTotalHeight;
  }
}
