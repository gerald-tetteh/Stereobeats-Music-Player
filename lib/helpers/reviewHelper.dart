/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Review Helper
*/

/*
  This class handles in app reviews.
  The user is promted a maximum of three times 
  over ninty days to leave a review in the app store.
*/

// imports
import 'package:hive/hive.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewHelper {
  final InAppReview inAppReview = InAppReview.instance;
  final DateTime date;
  ReviewHelper(this.date);

  bool isAfter(DateTime reviewDate) => date.isAfter(reviewDate);
  bool askCount(int number) => number < 3;

  /*
    This method is used to reset the database 
    each time the review dialog is shown.
    It also increases the count. i.e the number of
    times the review dialog has shown.
  */
  Future<void> reset(Box<String> box, String reviewCount) async {
    var nextReview = date.add(Duration(days: 30));
    var newCount = int.parse(reviewCount) + 1;
    await box.put("nextReview", nextReview.toIso8601String());
    await box.put(reviewCount, newCount.toString());
  }

  /*
    This method is used to show the dialog.
    The method checks if the device is compatible
    first and also if the review dialog can be shown 
    before showing it.
  */
  Future<void> showReview() async {
    var nextReviewDefault = date.add(Duration(days: 30));
    var box = Hive.box<String>("settings");
    var nextDate = box.get("nextReview");
    if (nextDate == null) {
      nextDate = nextReviewDefault.toIso8601String();
      await box.put("nextReview", nextDate);
    }
    var reviewCount = box.get("reviewCount", defaultValue: "0")!;
    if (askCount(int.parse(reviewCount))) {
      if (isAfter(DateTime.parse(nextDate))) {
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          await reset(box, reviewCount);
        }
      }
    }
  }
}
