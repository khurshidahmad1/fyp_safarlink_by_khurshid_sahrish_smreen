import 'package:get/get.dart';
import 'app_routes.dart';

// ── Existing modules ──────────────────────────────────────────────────────────
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/role_selection/role_view.dart';
import '../modules/auth/phone_auth/bindings/phone_auth_binding.dart';
import '../modules/auth/phone_auth/views/phone_input_view.dart';
import '../modules/auth/phone_auth/views/otp_verify_view.dart';
import '../modules/auth/email_auth/bindings/email_auth_binding.dart';
import '../modules/auth/email_auth/views/email_auth_view.dart';
import '../modules/passenger/booking_setup/passenger_booking_setup_view.dart';
import '../modules/passenger/booking_setup/passenger_booking_setup_binding.dart';
import '../modules/passenger/dashboard/passenger_dashboard_view.dart';
import '../modules/passenger/dashboard/passenger_dashboard_binding.dart';
import '../modules/passenger/car_details/car_details_view.dart';
import '../modules/passenger/car_details/car_details_binding.dart';
import '../modules/passenger/main_wrapper/passenger_main_wrapper_view.dart';
import '../modules/passenger/main_wrapper/passenger_main_wrapper_binding.dart';
import '../modules/passenger/profile/passenger_profile_view.dart';
import '../modules/passenger/profile/passenger_profile_binding.dart';
import '../modules/driver/car_registration/car_registration_view.dart';
import '../modules/driver/car_registration/bindings/car_registration_binding.dart';
import '../modules/driver/calendar/driver_calendar_view.dart';
import '../modules/driver/calendar/bindings/driver_calendar_binding.dart';
import '../modules/driver/booking_management/booking_management_view.dart';
import '../modules/driver/booking_management/bindings/booking_management_binding.dart';
import '../modules/shared/trip_details/trip_details_view.dart';
import '../modules/shared/trip_details/bindings/trip_details_binding.dart';

// ── Driver Dashboard (v2) ─────────────────────────────────────────────────────
import '../modules/driver/dashboard/driver_dashboard_view.dart';
import '../modules/driver/dashboard/bindings/driver_dashboard_binding.dart';

// ── Driver Module v2 — NEW pages ─────────────────────────────────────────────
import '../modules/driver/driver_kyc/driver_kyc_view.dart';
import '../modules/driver/driver_kyc/bindings/driver_kyc_binding.dart';
import '../modules/driver/vehicle_listing/vehicle_listing_view.dart';
import '../modules/driver/vehicle_listing/bindings/vehicle_listing_binding.dart';
import '../modules/driver/requests/requests_view.dart';
import '../modules/driver/requests/bindings/requests_hub_binding.dart';
import '../modules/driver/trips/driver_trips_view.dart';
import '../modules/driver/trips/bindings/driver_trips_binding.dart';
import '../modules/driver/profile_settings/driver_profile_settings_view.dart';
import '../modules/driver/profile_settings/bindings/driver_profile_settings_binding.dart';
import '../modules/driver/profile/edit_profile_view.dart';
import '../modules/driver/profile/bindings/edit_profile_binding.dart';
import '../modules/driver/my_vehicles_list/my_vehicles_list_view.dart';
import '../modules/driver/my_vehicles_list/bindings/my_vehicles_list_binding.dart';

class AppPages {
  static final pages = [
    // ── Auth & Splash ────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ROLE_SELECTION,
      page: () => const RoleView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PHONE_INPUT,
      page: () => const PhoneInputView(),
      binding: PhoneAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP_VERIFY,
      page: () => const OtpVerifyView(),
      binding: PhoneAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.EMAIL_AUTH,
      page: () => const EmailAuthView(),
      binding: EmailAuthBinding(),
    ),

    // ── Passenger ────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.PASSENGER_HOME,
      page: () => const PassengerMainWrapperView(),
      binding: PassengerMainWrapperBinding(),
    ),
    GetPage(
      name: AppRoutes.PASSENGER_PROFILE,
      page: () => const PassengerProfileView(),
      binding: PassengerProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.TRIP_DETAILS,
      page: () => const TripDetailsView(),
      binding: TripDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PASSENGER_BOOKING_SETUP,
      page: () => const PassengerBookingSetupView(),
      binding: PassengerBookingSetupBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.PASSENGER_DASHBOARD,
      page: () => const PassengerDashboardView(),
      binding: PassengerDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.CAR_DETAILS,
      page: () => const CarDetailsView(),
      binding: CarDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.BOOKING_SETUP,
      page: () => const PassengerBookingSetupView(),
      binding: PassengerBookingSetupBinding(),
      transition: Transition.rightToLeft,
    ),

    // ── Driver Dashboard (used for both DRIVER_HOME and DRIVER_DASHBOARD) ────
    GetPage(
      name: AppRoutes.DRIVER_HOME,
      page: () => const DriverDashboardView(),
      binding: DriverDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.DRIVER_DASHBOARD,
      page: () => const DriverDashboardView(),
      binding: DriverDashboardBinding(),
    ),

    // ── Legacy Driver Pages ───────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.CAR_REGISTRATION,
      page: () => const CarRegistrationView(),
      binding: CarRegistrationBinding(),
    ),
    GetPage(
      name: AppRoutes.DRIVER_CALENDAR,
      page: () => const DriverCalendarView(),
      binding: DriverCalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.BOOKING_MANAGEMENT,
      page: () => const BookingManagementView(),
      binding: BookingManagementBinding(),
    ),

    // ── Driver Module v2 — NEW ────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.DRIVER_KYC_SETUP,
      page: () => const DriverKycView(),
      binding: DriverKycBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.VEHICLE_LISTING,
      page: () => const VehicleListingView(),
      binding: VehicleListingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.DRIVER_REQUESTS_HUB,
      page: () => const RequestsHubView(),
      binding: RequestsHubBinding(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: AppRoutes.TRIP_MANAGEMENT,
      page: () => const DriverTripsView(),
      binding: DriverTripsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.DRIVER_PROFILE_SETTINGS,
      page: () => const DriverProfileSettingsView(),
      binding: DriverProfileSettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.EDIT_DRIVER_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.MY_VEHICLES_LIST,
      page: () => const MyVehiclesListView(),
      binding: MyVehiclesListBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
