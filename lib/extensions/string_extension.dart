extension StringExtention on String {
  String capitalize() {
    var stringParts = this.split(" ");
    return stringParts
        .map((string) => "${string[0].toUpperCase()}${string.substring(1)}")
        .join(" ");
  }
}
