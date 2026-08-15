class EditConfig {
  final double brightness;
  final double contrast;
  final double saturation;
  final double rotation;
  final bool isFlippedHorizontal;
  final bool isFlippedVertical;
  final String? filterName;

  EditConfig({
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.rotation = 0.0,
    this.isFlippedHorizontal = false,
    this.isFlippedVertical = false,
    this.filterName,
  });

  EditConfig copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? rotation,
    bool? isFlippedHorizontal,
    bool? isFlippedVertical,
    String? filterName,
  }) {
    return EditConfig(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      rotation: rotation ?? this.rotation,
      isFlippedHorizontal: isFlippedHorizontal ?? this.isFlippedHorizontal,
      isFlippedVertical: isFlippedVertical ?? this.isFlippedVertical,
      filterName: filterName ?? this.filterName,
    );
  }
}
