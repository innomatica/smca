// DIN 02322455 // ABILIFY
// DIN00000175 // ERYTHROCIN IV
// DIN00482323 // NOVO-GESIC FORTE
// DIN00559407 // Tylenol Extra Strength
// NPN80052230 // various hydrocortisone 1% cream
// NPN80037227 // Centrum Forte Essential
// DIN-HM80021809 //  kids les zamis gastro
// DIN-HM 80019696 // Dr. Reckeweg R71
// DIN-HM 80094024 // Quietude

const urlHealthProductsCanada = 'https://health-products.canada.ca';
const urlDpdWeb = '$urlHealthProductsCanada/dpd-bdpp';
const urlDpdApi = '$urlHealthProductsCanada/api/drug';
const String urlIllegalMarketing =
    'https://www.canada.ca/en/health-canada/services/drugs-health-products'
    '/marketing-drugs-devices/illegal-marketing/complaint-form.html';
const String urlReportSideEffect =
    'https://www.canada.ca/en/health-canada/services/drugs-health-products'
    '/medeffect-canada/adverse-reaction-reporting/drug.html';
const String urlAdverseReactionDatabase =
    'https://www.canada.ca/en/health-canada/services/drugs-health-products'
    '/medeffect-canada/adverse-reaction-database'
    '/medeffect-canada-caveat-privacy-statement-interpretation-data-search'
    '-canada-vigilance-adverse-reaction-online-database.html';
const String urlAdverseReactionDatabaseDirect =
    'https://cvp-pcv.hc-sc.gc.ca/arq-rei/index-eng.jsp';
const String urlRecallsSafetyAlerts =
    'https://recalls-rappels.canada.ca/en/search/site';

const urlMedlinePlus = 'https://medlineplus.gov/';
const urlPrivacyPolicy = 'https://innomatica.github.io/smca/privacy/';
const urlDisclaimer = 'https://innomatica.github.io/smca/disclaimer/';
const urlWikipedia = 'https://www.wikipedia.org';

const urlMedicineIcons = 'https://www.flaticon.com/free-icons/medicine';
const urlBackgroundImage = 'https://unsplash.com/@anshu18';

// notification
const useInboxNotification = true;
const notificationChannelId = 'com.innomatic.smca.schedule';
const notificationChannelName = 'SafeMed Schedule Alarm';
const notificationChannelDescription = 'SafeMed Schedule Alarm';

bool enableExperimentalFeatures = true;

// provisioning
const int provisionTimeoutSec = 50;
