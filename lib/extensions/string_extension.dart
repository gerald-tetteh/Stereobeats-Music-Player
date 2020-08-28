/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * String Extension
*/

/*
  This file contains an extension on the string class.
*/

extension StringExtension on String {
  /*
    This function converts the first letter of each
    word from lower to upper case. It is non distructive.
  */
  String capitalize() {
    var stringParts = this.split(" ");
    return stringParts
        .map((string) => "${string[0].toUpperCase()}${string.substring(1)}")
        .join(" ");
  }
}
