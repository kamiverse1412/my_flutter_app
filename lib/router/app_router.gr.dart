// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:astra_mobile/account.dart';
import 'package:astra_mobile/cart.dart' as _i1;
import 'package:astra_mobile/catalog.dart' as _i2;
import 'package:astra_mobile/details.dart' as _i4;
import 'package:astra_mobile/face_id_screen.dart';
import 'package:astra_mobile/filterpage.dart' as _i5;
import 'package:astra_mobile/lang.dart';
import 'package:astra_mobile/liked.dart';
import 'package:astra_mobile/login.dart' as _i6;
import 'package:astra_mobile/personal.dart' as _i7;
import 'package:astra_mobile/profile.dart' as _i3;
import 'package:astra_mobile/register.dart';
import 'package:astra_mobile/results.dart' as _i8;
import 'package:astra_mobile/selected.dart';
import 'package:astra_mobile/shop.dart' as _i9;
import 'package:astra_mobile/splash.dart' as _i10;
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:collection/collection.dart' as _i13;
import 'package:flutter/material.dart' as _i12;

/// generated route for
/// [AccountPage]
class AccountRoute extends _i11.PageRouteInfo<void> {
  const AccountRoute({List<_i11.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const AccountPage();
    },
  );
}

/// generated route for
/// [_i1.CartPage]
class CartRoute extends _i11.PageRouteInfo<void> {
  const CartRoute({List<_i11.PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i1.CartPage();
    },
  );
}

/// generated route for
/// [_i2.CatalogPage]
class CatalogRoute extends _i11.PageRouteInfo<void> {
  const CatalogRoute({List<_i11.PageRouteInfo>? children})
    : super(CatalogRoute.name, initialChildren: children);

  static const String name = 'CatalogRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i2.CatalogPage();
    },
  );
}

/// generated route for
/// [_i3.CheckPage]
class CheckRoute extends _i11.PageRouteInfo<void> {
  const CheckRoute({List<_i11.PageRouteInfo>? children})
    : super(CheckRoute.name, initialChildren: children);

  static const String name = 'CheckRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i3.CheckPage();
    },
  );
}

/// generated route for
/// [_i4.DetailsPage]
class DetailsRoute extends _i11.PageRouteInfo<DetailsRouteArgs> {
  DetailsRoute({
    _i12.Key? key,
    required Map<String, dynamic> product,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         DetailsRoute.name,
         args: DetailsRouteArgs(key: key, product: product),
         initialChildren: children,
       );

  static const String name = 'DetailsRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DetailsRouteArgs>();
      return _i4.DetailsPage(key: args.key, product: args.product);
    },
  );
}

class DetailsRouteArgs {
  const DetailsRouteArgs({this.key, required this.product});

  final _i12.Key? key;

  final Map<String, dynamic> product;

  @override
  String toString() {
    return 'DetailsRouteArgs{key: $key, product: $product}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DetailsRouteArgs) return false;
    return key == other.key &&
        const _i13.MapEquality().equals(product, other.product);
  }

  @override
  int get hashCode => key.hashCode ^ const _i13.MapEquality().hash(product);
}

/// generated route for
/// [FaceIdPage]
class FaceIdRoute extends _i11.PageRouteInfo<FaceIdRouteArgs> {
  FaceIdRoute({
    _i12.Key? key,
    String? phone,
    String? password,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         FaceIdRoute.name,
         args: FaceIdRouteArgs(key: key, phone: phone, password: password),
         initialChildren: children,
       );

  static const String name = 'FaceIdRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FaceIdRouteArgs>(
        orElse: () => const FaceIdRouteArgs(),
      );
      return FaceIdPage(
        key: args.key,
        phone: args.phone,
        password: args.password,
      );
    },
  );
}

class FaceIdRouteArgs {
  const FaceIdRouteArgs({this.key, this.phone, this.password});

  final _i12.Key? key;

  final String? phone;

  final String? password;

  @override
  String toString() {
    return 'FaceIdRouteArgs{key: $key, phone: $phone, password: $password}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FaceIdRouteArgs) return false;
    return key == other.key &&
        phone == other.phone &&
        password == other.password;
  }

  @override
  int get hashCode => key.hashCode ^ phone.hashCode ^ password.hashCode;
}

/// generated route for
/// [_i5.FilterPage]
class FilterRoute extends _i11.PageRouteInfo<void> {
  const FilterRoute({List<_i11.PageRouteInfo>? children})
    : super(FilterRoute.name, initialChildren: children);

  static const String name = 'FilterRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i5.FilterPage();
    },
  );
}

/// generated route for
/// [LanguagePage]
class LanguageRoute extends _i11.PageRouteInfo<void> {
  const LanguageRoute({List<_i11.PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const LanguagePage();
    },
  );
}

/// generated route for
/// [LikePage]
class LikeRoute extends _i11.PageRouteInfo<void> {
  const LikeRoute({List<_i11.PageRouteInfo>? children})
    : super(LikeRoute.name, initialChildren: children);

  static const String name = 'LikeRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const LikePage();
    },
  );
}

/// generated route for
/// [_i6.LoginPage]
class LoginRoute extends _i11.PageRouteInfo<void> {
  const LoginRoute({List<_i11.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i6.LoginPage();
    },
  );
}

/// generated route for
/// [_i7.PersonalPage]
class PersonalRoute extends _i11.PageRouteInfo<void> {
  const PersonalRoute({List<_i11.PageRouteInfo>? children})
    : super(PersonalRoute.name, initialChildren: children);

  static const String name = 'PersonalRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i7.PersonalPage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends _i11.PageRouteInfo<void> {
  const RegisterRoute({List<_i11.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [_i8.ResultsPage]
class ResultsRoute extends _i11.PageRouteInfo<void> {
  const ResultsRoute({List<_i11.PageRouteInfo>? children})
    : super(ResultsRoute.name, initialChildren: children);

  static const String name = 'ResultsRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i8.ResultsPage();
    },
  );
}

/// generated route for
/// [SelectedPage]
class SelectedRoute extends _i11.PageRouteInfo<SelectedRouteArgs> {
  SelectedRoute({
    _i12.Key? key,
    required String categoryName,
    required String categoryId,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         SelectedRoute.name,
         args: SelectedRouteArgs(
           key: key,
           categoryName: categoryName,
           categoryId: categoryId,
         ),
         initialChildren: children,
       );

  static const String name = 'SelectedRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SelectedRouteArgs>();
      return SelectedPage(
        key: args.key,
        categoryName: args.categoryName,
        categoryId: args.categoryId,
      );
    },
  );
}

class SelectedRouteArgs {
  const SelectedRouteArgs({
    this.key,
    required this.categoryName,
    required this.categoryId,
  });

  final _i12.Key? key;

  final String categoryName;

  final String categoryId;

  @override
  String toString() {
    return 'SelectedRouteArgs{key: $key, categoryName: $categoryName, categoryId: $categoryId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SelectedRouteArgs) return false;
    return key == other.key &&
        categoryName == other.categoryName &&
        categoryId == other.categoryId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ categoryName.hashCode ^ categoryId.hashCode;
}

/// generated route for
/// [_i9.ShopPage]
class ShopRoute extends _i11.PageRouteInfo<void> {
  const ShopRoute({List<_i11.PageRouteInfo>? children})
    : super(ShopRoute.name, initialChildren: children);

  static const String name = 'ShopRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i9.ShopPage();
    },
  );
}

/// generated route for
/// [_i10.SplashPage]
class SplashRoute extends _i11.PageRouteInfo<void> {
  const SplashRoute({List<_i11.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i10.SplashPage();
    },
  );
}
