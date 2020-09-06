import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewHelper {
  final InAppReview inAppReview = InAppReview.instance;
  final DateTime date;
  ReviewHelper(this.date);

  bool isAfter(DateTime reviewDate) => date.isAfter(reviewDate);
  bool askCount(int number) => number < 3;
  bool hasAsked(String value) => value == "1";

  void reset(Box<String> box, String reviewCount, int year,
      [bool newYear = false]) {
    var nextReview = date.add(Duration(days: 30));
    var newCount = newYear ? 0 : int.parse(reviewCount) + 1;
    box.put("nextReview", nextReview.toIso8601String());
    box.put("savedYear", year.toString());
    box.put(reviewCount, newCount.toString());
  }

  Future<void> showReview() async {
    final year = date.year;
    var nextReviewDefault = date.add(Duration(days: 30));
    var box = Hive.box<String>("settings");
    var hasAsked = box.get("hasAsked", defaultValue: "0");
    // TODO: Check if user has submitted a review.
    var nextDate = box.get("nextReview",
        defaultValue: "${nextReviewDefault.toIso8601String()}");
    var savedYear = box.get("savedYear", defaultValue: year.toString());
    var reviewCount = box.get("reviewCount", defaultValue: "0");
    if (int.parse(savedYear) == year) {
      if (askCount(int.parse(reviewCount))) {
        if (isAfter(DateTime.parse(nextDate))) {
          if (await inAppReview.isAvailable()) {
            await inAppReview.requestReview();
            reset(box, reviewCount, year);
          }
        }
      }
    } else {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        reset(box, reviewCount, year, true);
      }
    }
  }
}
