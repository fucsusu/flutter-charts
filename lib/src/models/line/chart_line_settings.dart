part of 'chart_line_layer.dart';

typedef PointBuild = void Function(Offset offset, Canvas canvas);

/// A collection of values for settings in lines.
class ChartLineSettings {
  /// The color of lines.
  final Color color;

  /// The thickness of lines.
  final double thickness;

  /// 是否拐点是否使用平滑曲线
  final bool useCurve;

  /// 点位显示的样式
  final PointBuild? pointBuild;

  const ChartLineSettings({
    required this.color,
    required this.thickness,
    this.useCurve = true,
    this.pointBuild,
  });
}
