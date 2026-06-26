# TODO - Fix compilation errors (Flutter)

## Step 1 - App theme type fixes
- [ ] lib/config/app_config.dart: change `cardTheme: CardTheme(...)` -> `cardTheme: CardThemeData(...)`
- [ ] lib/config/app_config.dart: change `dialogTheme: DialogTheme(...)` -> `dialogTheme: DialogThemeData(...)`

## Step 2 - Dialog `_` identifier fixes
- [ ] lib/screens/admin/validation_screen.dart: replace `Navigator.pop(_, ...)` with `Navigator.pop(context, ...)`
- [ ] lib/screens/profile/profile_screen.dart: replace `Navigator.pop(_, ...)` with `Navigator.pop(ctx, ...)` (or correct context variable)

## Step 3 - const-expression fix
- [x] lib/screens/items/item_detail_screen.dart: remove offending `const` where `const_eval_method_invocation` occurs

## Step 4 - map_screen Path mismatch fix
- [ ] lib/screens/items/map_screen.dart: fix undefined methods / Path type mismatch around reported lines (~225-229)

## Step 5 - widget test fix
- [ ] test/widget_test.dart: replace `MyApp` with correct app widget (`ObjetsPerdusDuCampusApp`) or add `MyApp` alias

## Step 6 - Verify
- [ ] Run `flutter analyze` until 0 errors
- [ ] Run `flutter test` (optional) to ensure tests compile

