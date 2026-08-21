import 'package:accurate/utils/splash_screen.dart';
import 'package:accurate/views/authentication/login.dart';
import 'package:accurate/views/dashboard/dashboard.dart';
import 'package:accurate/views/layout/about_us.dart';
import 'package:accurate/views/layout/contact_us.dart';
import 'package:accurate/views/layout/my_cart.dart';
import 'package:accurate/views/layout/product.dart';
import 'package:accurate/views/layout/product_details.dart';
import 'package:accurate/views/layout/wishlist.dart';
import 'package:get/get.dart';

class RoutesManager {
  static String getLoginRoute() => LoginPage.routeName;

  static String getSplashRoute() => SplashScreen.routeName;

  static String getDashboardRoute() => Dashboard.routeName;

  static String getMyCartRoute() => MyCart.routeName;

  static String getContactUs() => ContactUs.routeName;

  static String getAboutUs() => AboutUs.routeName;

  static String getWishList() => WishList.routeName;

  static String getProductList() => Product.routeName;

  static String getProductDetails() => ProductDetails.routeName;

  static List<GetPage> appRoutes() => [
        GetPage(
          name: SplashScreen.routeName,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: LoginPage.routeName,
          page: () => LoginPage(),
        ),
        GetPage(
          name: Dashboard.routeName,
          page: () => Dashboard(),
        ),
        GetPage(
          name: MyCart.routeName,
          page: () => MyCart(),
        ),
        GetPage(
          name: ContactUs.routeName,
          page: () => ContactUs(),
        ),
        GetPage(
          name: AboutUs.routeName,
          page: () => AboutUs(),
        ),
        GetPage(
          name: WishList.routeName,
          page: () => WishList(),
        ),
        GetPage(
          name: Product.routeName,
          page: () => Product(),
        ),
        GetPage(
          name: ProductDetails.routeName,
          page: () => ProductDetails(),
        )
      ];
}
