import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('sr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Beehives'**
  String get appTitle;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQR;

  /// No description provided for @addHive.
  ///
  /// In en, this message translates to:
  /// **'Add New Hive'**
  String get addHive;

  /// No description provided for @viewHives.
  ///
  /// In en, this message translates to:
  /// **'View All Hives'**
  String get viewHives;

  /// No description provided for @exportAllData.
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllData;

  /// No description provided for @exportForOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Export for Other Device'**
  String get exportForOtherDevice;

  /// No description provided for @importFromOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Import from Other Device'**
  String get importFromOtherDevice;

  /// No description provided for @addNewHiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Hive'**
  String get addNewHiveTitle;

  /// No description provided for @hiveId.
  ///
  /// In en, this message translates to:
  /// **'Hive ID'**
  String get hiveId;

  /// No description provided for @hiveName.
  ///
  /// In en, this message translates to:
  /// **'Hive Name'**
  String get hiveName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @hiveType.
  ///
  /// In en, this message translates to:
  /// **'Hive type'**
  String get hiveType;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @addStatus.
  ///
  /// In en, this message translates to:
  /// **'Add status'**
  String get addStatus;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes entered.'**
  String get noNotes;

  /// No description provided for @viewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View full history'**
  String get viewFullHistory;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images for this hive.'**
  String get noImages;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @brood.
  ///
  /// In en, this message translates to:
  /// **'Brood'**
  String get brood;

  /// No description provided for @honey.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get honey;

  /// No description provided for @hiveSaved.
  ///
  /// In en, this message translates to:
  /// **'Hive saved'**
  String get hiveSaved;

  /// No description provided for @allHivesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Hives'**
  String get allHivesTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortById.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get sortById;

  /// No description provided for @noHivesFound.
  ///
  /// In en, this message translates to:
  /// **'No hives found.'**
  String get noHivesFound;

  /// No description provided for @searchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLabel;

  /// No description provided for @noNameLabel.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noNameLabel;

  /// No description provided for @queenSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Queen status'**
  String get queenSectionTitle;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @hiveStrength.
  ///
  /// In en, this message translates to:
  /// **'Colony strength'**
  String get hiveStrength;

  /// No description provided for @hiveBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get hiveBreed;

  /// No description provided for @queen.
  ///
  /// In en, this message translates to:
  /// **'Queen'**
  String get queen;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'sr': return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
