import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:land_house_verify/components/show_dialog.dart';
import 'package:land_house_verify/services/email_service.dart';
import 'package:land_house_verify/services/register_validator_service.dart';
import 'package:land_house_verify/services/validation_data_service.dart';

import 'services/asset_register_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Register services as singletons
  getIt.registerLazySingleton<EmailSend>(() => EmailSend());
  getIt.registerLazySingleton<RegisterValidatorService>(
      () => RegisterValidatorService());
  getIt.registerLazySingleton<AssetRegisterService>(
      () => AssetRegisterService());
  getIt.registerLazySingleton<ShowConfirmationDialogClass>(
      () => ShowConfirmationDialogClass());
  getIt.registerLazySingleton<ValidationService>(
    () => ValidationService(),
  );
}
