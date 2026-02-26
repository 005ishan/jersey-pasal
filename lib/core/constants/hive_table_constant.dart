class HiveTableConstant {
  HiveTableConstant._();

  static const String dbName = 'jersey-pasal';

  static const int favouriteTypeId = 0;
  static const String favouriteTable = 'favourite_table';

  static const int itemTypeId = 1;
  static const String itemTable = 'item_table';

  static const int authTypeId = 2;
  static const String authTable = 'auth_table';

  static const int categoryTypeId = 3;
  static const String categoryTable = 'category_table';

  static const int commentsTypeId = 4;
  static const String commentsTable = 'comments_table';

  // ─── Fix: use 5 and 6 to avoid conflicts ───
  static const int orderTypeId = 5;
  static const int orderItemTypeId = 6;
  static const String orderTable = 'order_history';
}