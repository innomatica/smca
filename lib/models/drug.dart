import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../shared/helpers.dart';

class Drug {
  int id;
  String drugId;
  String drugName;
  String drugType; // DIN, NPN, DIN-HM
  String frequency;
  Map drugInfo;
  Map dosageInfo;
  Map companyInfo;
  Map consumerInfo;
  Map? prescriptionInfo;
  Map? recallInfo;
  Map? efficacyInfo;
  Map? warningInfo;
  Map? durInfo;

  Drug({
    required this.id,
    required this.drugId,
    required this.drugName,
    required this.drugType,
    required this.frequency,
    required this.drugInfo,
    required this.dosageInfo,
    required this.companyInfo,
    required this.consumerInfo,
    this.prescriptionInfo,
    this.recallInfo,
    this.warningInfo,
    this.efficacyInfo,
    this.durInfo,
  });

  factory Drug.fromDatabaseJson(Map<String, dynamic> data) {
    return Drug(
      id: data['id'],
      drugId: data['drugId'],
      drugName: data['drugName'],
      drugType: data['drugType'],
      frequency: data['frequency'],
      drugInfo: jsonDecode(data['drugInfo']),
      dosageInfo: jsonDecode(data['dosageInfo']),
      companyInfo: jsonDecode(data['companyInfo']),
      prescriptionInfo: jsonDecode(data['prescriptionInfo']) ?? {},
      consumerInfo: jsonDecode(data['consumerInfo']) ?? {},
      recallInfo: jsonDecode(data['recallInfo']) ?? {},
      efficacyInfo: jsonDecode(data['efficacyInfo']) ?? {},
      warningInfo: jsonDecode(data['warningInfo']) ?? {},
      durInfo: jsonDecode(data['durInfo']) ?? {},
    );
  }

  factory Drug.fromDpdApi(Map<String, dynamic> item) {
    return Drug(
      id: getDatabaseId(),
      drugId: item['drug_identification_number'],
      drugName: item['brand_name'],
      drugType: 'DIN',
      frequency: standardRegimen.entries.first.key,
      drugInfo: {
        'drug_code': item['drug_code'], // INT
        'class_name': item['class_name'],
        'descriptor': item['descriptor'],
        'number_of_ais': int.tryParse(item['number_of_ais']) ?? 0,
        'ai_group_no': item['ai_group_no'],
        'last_update_date': item['last_update_date'],
        // "activeingredient": [
        //   {
        //     "dosage_unit": "",
        //     "dosage_value": "",
        //     "drug_code": 48905,
        //     "ingredient_name": "VITAMIN A",
        //     "strength": "1250",
        //     "strength_unit": "UNIT"
        //   },
        // ],
        // "packaging": [
        //   {
        //     "drug_code": 11685,
        //     "upc": "055599047240",
        //     "package_size_unit": "24",
        //     "package_type": "Blister Pack",
        //     "package_size": "Ea",
        //     "product_information": ""
        //   }
        // ],
        // "standard": [
        //   {"drug_code": 11534, "pharmaceutical_std": "MFR"}
        // ],
        // "schedule": [
        //   {"drug_code": 10687, "schedule_name": "Prescription"},
        //   {"drug_code": 10687, "schedule_name": "Schedule D"}
        // ],
        // "status": [
        //   {
        //     "drug_code": 10229,
        //     "status": "Cancelled Post Market",
        //     "history_date": "1997-10-15",
        //     "original_market_date": "1989-12-31",
        //     "external_status_code": 4,
        //     "expiration_date": null,
        //     "lot_number": 0
        //   }
        // ],
        // "class": [
        //   {
        //     "drug_code": 10564,
        //     "tc_atc_number": "V07AV",
        //     "tc_atc": "TECHNICAL DISINFECTANTS",
        //     "tc_ahfs_number": "38:00.00",
        //     "tc_ahfs": "DISINFECTANTS (FOR AGENTS USED ON OBJECT)"
        //   }
        // ],
      },
      dosageInfo: {
        'dose': '1 Dose',
        // "form": [
        //   {
        //     "drug_code": 10846,
        //     "pharmaceutical_form_code": 34,
        //     "pharmaceutical_form_name": "Liquid"
        //   },
        //   {
        //     "drug_code": 10846,
        //     "pharmaceutical_form_code": 43,
        //     "pharmaceutical_form_name": "Ointment"
        //   }
        // ],
        // "route": [
        //   {
        //     "drug_code": 3,
        //     "route_of_administration_code": 10,
        //     "route_of_administration_name": "Intra-Articular"
        //   },
        //   {
        //     "drug_code": 3,
        //     "route_of_administration_code": 33,
        //     "route_of_administration_name": "Intraperitoneal"
        //   },
        // ],
      },
      companyInfo: {
        'company_name': item['company_name'],
        // 'company': [
        //   {
        //     "city_name": "Mississauga",
        //     "company_code": 10825,
        //     "company_name": "PAX-ALL MANUFACTURING INC.",
        //     "company_type": "DIN OWNER",
        //     "country_name": "Canada",
        //     "post_office_box": "",
        //     "postal_code": "L5S 1R7",
        //     "province_name": "Ontario",
        //     "street_name": "7115 Tomken Road",
        //     "suite_number": ""
        //   }
        // ],
      },
      consumerInfo: {},
      efficacyInfo: {},
      warningInfo: {},
      durInfo: {},
    );
  }

  factory Drug.fromLnhpdApi(Map<String, dynamic> item, String prefix) {
    return Drug(
      id: getDatabaseId(),
      drugId: item['licence_number'],
      drugName: item['product_name'],
      drugType: prefix,
      frequency: standardRegimen.entries.first.key,
      drugInfo: {
        "lnhpd_id": item['lnhpd_id'], // INT
        "licence_date": item['licence_date'],
        "revised_date": item['revised_date'],
        "time_receipt": item['time_receipt'],
        "date_start": item['date_start'],
        "product_name_id": item['product_name_id'], // INT
        "sub_submission_type_code": item['sub_submission_type_code'], // INT
        "sub_submission_type_desc": item['sub_submission_type_desc'],
        "flag_primary_name": item['flag_primary_name'],
        "flag_product_status": item['flag_product_status'],
        "flag_attested_monograph": item['flag_attested_monograph'],
        // "medicinalingredient": [
        //   {
        //     "lnhpd_id": 3894657,
        //     "ingredient_name": "Valeriana officinalis",
        //     "ingredient_Text": null,
        //     "potency_amount": 0.0,
        //     "potency_constituent": "",
        //     "potency_unit_of_measure": "",
        //     "quantity": 80.0,
        //     "quantity_minimum": 0,
        //     "quantity_maximum": 0,
        //     "quantity_unit_of_measure": "mg",
        //     "ratio_numerator": "5",
        //     "ratio_denominator": "1",
        //     "dried_herb_equivalent": "400",
        //     "dhe_unit_of_measure": "mg",
        //     "extract_type_desc": "",
        //     "source_material": "Root"
        //   },
        // ],
        // "nonmedicinalingedient": [
        //   {"lnhpd_id": 3894852, "ingredient_name": "Annatto"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Artificial Orange Flavor"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Cellulose"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Dextrose"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Fructose"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Magnesium Stearate"},
        //   {"lnhpd_id": 3894852, "ingredient_name": "Stearic Acid"}
        // ],
        // "productlicence": [
        //   {
        //     "lnhpd_id": 3894930,
        //     "licence_number": "02096870",
        //     "licence_date": "2004-10-15",
        //     "revised_date": null,
        //     "time_receipt": "2004-01-13",
        //     "date_start": "2004-01-19",
        //     "product_name_id": 170030,
        //     "product_name": "Primanol",
        //     "dosage_form": "Capsule",
        //     "company_id": 10152,
        //     "company_name_id": 9141709,
        //     "company_name": "Jamieson Laboratories Ltd.",
        //     "sub_submission_type_code": 5,
        //     "sub_submission_type_desc": "Transitional DIN",
        //     "flag_primary_name": 1,
        //     "flag_product_status": 1,
        //     "flag_attested_monograph": 0
        //   }
        // ],
        // "productpurpose": [
        //   {
        //     "text_id": 67880,
        //     "lnhpd_id": 3931278,
        //     "purpose": "Helps to rebuild cartilage and aids to relieve ..."
        //   }
        // ],
        // "productrisk": [
        //   {
        //     "lnhpd_id": 3898401,
        //     "risk_id": 12855,
        //     "risk_type_desc": "Cautions and Warnings",
        //     "sub_risk_type_desc": "",
        //     "risk_text":
        //         "Consult a health care provider prior to use if: you ..."
        //   },
        // ],
      },
      dosageInfo: {
        'dose': '1 Dose',
        "dosage_form": item['dosage_form'],
        // "productdose": [
        //   {
        //     "lnhpd_id": 3908931,
        //     "dose_id": 5884617,
        //     "population_type_desc": "Adults",
        //     "age": 0,
        //     "age_minimum": 0.0,
        //     "age_maximum": 0.0,
        //     "uom_type_desc_age": "",
        //     "quantity_dose": 2.0,
        //     "quantity_dose_minimum": 0.0,
        //     "quantity_dose_maximum": 0.0,
        //     "uom_type_desc_quantity_dose": "tablet",
        //     "frequency": 1.0,
        //     "frequency_minimum": 0.0,
        //     "frequency_maximum": 0.0,
        //     "uom_type_desc_frequency": "daily"
        //   }
        // ],
        // "productroute": [
        //   {
        //     "lnhpd_id": 3894930,
        //     "route_id": 170060,
        //     "route_type_desc": "Oral",
        //   }
        // ],
      },
      companyInfo: {
        "company_id": item['company_id'],
        "company_name_id": item['company_name_id'],
        'company_name': item['company_name'],
      },
      consumerInfo: {},
      efficacyInfo: {},
      warningInfo: {},
      durInfo: {},
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'drugId': drugId,
      'drugName': drugName,
      'drugType': drugType,
      'frequency': frequency,
      'drugInfo': jsonEncode(drugInfo),
      'dosageInfo': jsonEncode(dosageInfo),
      'companyInfo': jsonEncode(companyInfo),
      'consumerInfo': jsonEncode(consumerInfo),
      'prescriptionInfo': jsonEncode(prescriptionInfo ?? {}),
      'recallInfo': jsonEncode(recallInfo ?? {}),
      'efficacyInfo': jsonEncode(efficacyInfo ?? {}),
      'warningInfo': jsonEncode(warningInfo ?? {}),
      'durInfo': jsonEncode(durInfo ?? {}),
    };
  }

  @override
  String toString() {
    return toDatabaseJson().toString();
  }

  Widget getIcon({Color? color, double? size}) {
    String dosageForm = 'UNKNOWN';
    if (drugType == 'DIN') {
      if (dosageInfo.containsKey('form') && (dosageInfo['form'].isNotEmpty)) {
        dosageForm =
            dosageInfo['form'][0]['pharmaceutical_form_name']?.toUpperCase();
      }
    } else {
      dosageForm = dosageInfo['dosage_form']?.toUpperCase();
    }

    if (dosageForm.contains('PILL') ||
        dosageForm.contains('TABLET') ||
        dosageForm.contains('CAPSULE') ||
        dosageForm.contains('LOZENGE')) {
      return FaIcon(FontAwesomeIcons.pills, color: color, size: size);
    } else if (dosageForm.contains('DROPS')) {
      return FaIcon(FontAwesomeIcons.eyeDropper, color: color, size: size);
    } else if (dosageForm.contains('INJECTION')) {
      return FaIcon(FontAwesomeIcons.syringe, color: color, size: size);
    } else if (dosageForm.contains('AEROSOL') || dosageForm.contains('SPRAY')) {
      return FaIcon(FontAwesomeIcons.sprayCan, color: color, size: size);
    } else if (dosageForm.contains('POWDER')) {
      return FaIcon(FontAwesomeIcons.mortarPestle, color: color, size: size);
    } else if (dosageForm.contains('BANDAGE')) {
      return FaIcon(FontAwesomeIcons.bandage, color: color, size: size);
    } else if (dosageForm.contains('CREAM') ||
        dosageForm.contains('GEL') ||
        dosageForm.contains('LOTION') ||
        dosageForm.contains('OINTMENT') ||
        dosageForm.contains('SHAMPOO') ||
        dosageForm.contains('STICK')) {
      return FaIcon(FontAwesomeIcons.handHoldingDroplet,
          color: color, size: size);
    } else if (dosageForm.contains('SOLUTION') ||
        dosageForm.contains('MOUTHWASH') ||
        dosageForm.contains('SYRUP') ||
        dosageForm.contains('LIQUID') ||
        dosageForm.contains('SUSPENSION')) {
      return FaIcon(FontAwesomeIcons.wineBottle, color: color, size: size);
    } else {
      return FaIcon(FontAwesomeIcons.prescriptionBottleMedical,
          color: color, size: size);
    }
  }
}

Map<String, List<DateTime>> standardRegimen = {
  'Once a Day': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
  ],
  '2 Times a Day': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  '3 Times a Day': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  '4 Times a Day': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  '5 Times a Day': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  'Every 3 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 3),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 15),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  'Every 4 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 1),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  'Every 6 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 6),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 24),
  ],
  'Every 8 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 24),
  ],
  'Every 12 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  'Every 24 Hours': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
  ],
  'Bedtime': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
  'With Meals': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
  ],
  'With Meals + Bedtime': [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  ],
};

Map<String, int> drugAlarmInterval = {
  'Once a Day': 24,
  '2 Times a Day': 12,
  '3 Times a Day': 8,
  '4 Times a Day': 6,
  '5 Times a Day': 5,
  'Every 3 Hours': 3,
  'Every 4 Hours': 4,
  'Every 6 Hours': 6,
  'Every 8 Hours': 8,
  'Every 12 Hours': 12,
  'Every 24 Hours': 24,
  'Bedtime': 24,
  'With Meals': 8,
  'With Meals + Bedtime': 6,
};
