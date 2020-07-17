class DefaultUtil {
  static const defaultImage = "assets/images/default-image.png";
  static const unknown = "Unknown";

  static bool checkNotNull(String value) {
    if (value != null && value.length > 0) {
      return true;
    }
    return false;
  }

  static bool checkNotAsset(String path) {
    if (path.contains("assets/images")) {
      return false;
    }
    return true;
  }
}
