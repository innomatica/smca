import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/drug.dart';
import '../../models/drug.dart';

class DrugDetails extends StatelessWidget {
  final Drug drug;
  const DrugDetails({required this.drug, super.key});

  @override
  Widget build(BuildContext context) {
    final drugBloc = context.read<DrugBloc>();
    // FIXME: 'activeingredient' is null why?
    final ingCount = drug.drugType == 'DIN'
        ? drug.drugInfo['activeingredient'].length
        : drug.drugInfo['medicinalingredient'].length;
    final ingList = drug.drugType == 'DIN'
        ? List<String>.generate(
            ingCount,
            (index) =>
                drug.drugInfo['activeingredient'][index]['ingredient_name'] +
                ' ' +
                drug.drugInfo['activeingredient'][index]['strength'] +
                ' ' +
                drug.drugInfo['activeingredient'][index]['strength_unit'])
        : List<String>.generate(
            ingCount,
            (index) =>
                drug.drugInfo['medicinalingredient'][index]['ingredient_name']);

    // debugPrint('drugInfo: ${drug.drugInfo.toString()}');
    // debugPrint('dosageInfo: ${drug.dosageInfo.toString()}');
    // debugPrint('consumerInfo: ${drug.consumerInfo.toString()}');

    //
    // Active Ingredients
    //
    Widget buildIngredientTile(BuildContext context, index) {
      String ingrFull = ingList[index];
      String ingrShort = ingrFull
          .substring(0, ingrFull.indexOf(RegExp(r'\s(?=\d)|\(')))
          .trim();
      final horzRef = MediaQuery.of(context).size.width / 2 - 100;
      final vertRef = MediaQuery.of(context).size.height / 2 - 10;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: Card(
          elevation: 4.0,
          child: ListTile(
            dense: true,
            title: Text(
              ingrFull,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onTap: () async {
              final launchUri = Uri(
                  scheme: 'https',
                  host: 'connect.medlineplus.gov',
                  path: '/service',
                  queryParameters: {
                    'mainSearchCriteria.v.cs': '2.16.840.1.113883.6.69',
                    'mainSearchCriteria.v.dn': Uri.encodeComponent(ingrShort),
                    'informationRecipient.languageCode.c': 'en',
                    'knowledgeResponseType': 'application/json',
                  });
              var res = await http.get(launchUri);
              final Map parsed = jsonDecode(res.body);

              List<PopupMenuEntry<String>> menu = [];
              for (final entry in parsed['feed']['entry']) {
                final url = entry['link'][0]['href'];
                String menuTitle;
                if (url.contains('medlineplus.gov')) {
                  if (url.contains('druginfo')) {
                    menuTitle = 'MedlinePlus(Drug Info)';
                  } else {
                    menuTitle = 'MedlinePlus';
                  }
                } else if (url.contains('cancer.gov')) {
                  menuTitle = 'National Cancer Institute';
                } else if (url.contains('nih.gov')) {
                  menuTitle = 'National Institute of Health';
                } else {
                  menuTitle = url;
                }
                menu.add(PopupMenuItem<String>(
                  value: url,
                  child: Text(menuTitle),
                ));
              }

              if (context.mounted) {
                if (menu.isNotEmpty) {
                  showMenu<String>(
                    context: context,
                    elevation: 8.0,
                    position: RelativeRect.fromLTRB(
                        horzRef, vertRef, horzRef, vertRef),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    items: menu,
                  ).then((ret) async {
                    if (ret != null) {
                      await launchUrl(Uri.parse(ret));
                    }
                  });
                  // final ret = await showMenu(
                  //   context: context,
                  //   elevation: 8.0,
                  //   position: RelativeRect.fromLTRB(
                  //       horzRef, vertRef, horzRef, vertRef),
                  //   shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  //   ),
                  //   items: menu,
                  // );
                  // if (ret != null) {
                  //   await launchUrl(Uri.parse(ret));
                  // }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Information not available')),
                  );
                }
              }
            },
          ),
        ),
      );
    }

    //
    // Drug Details
    //
    Widget buildDrugDetails() {
      return ListView(
        children: [
          //
          // Drug Type: DIN, NPN, DIN-HM
          //
          ListTile(
            title: Text(drug.drugType),
            subtitle: Text(
              drug.drugId,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          //
          // Schedule
          //
          ListTile(
            title: const Text('Schedule / Type'),
            subtitle: Text(
              drug.drugType == 'DIN'
                  ? drug.drugInfo['schedule'][0]['schedule_name']
                  : drug.drugInfo['sub_submission_type_desc'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          //
          // Manufacturer
          //
          ListTile(
            title: const Text('Manufacturer'),
            subtitle: Text(
              drug.companyInfo['company_name'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          //
          // Dosage From
          //
          ListTile(
            title: const Text('Dosage Form'),
            subtitle: Text(
              drug.drugType == 'DIN'
                  ? drug.dosageInfo['form'][0]['pharmaceutical_form_name']
                  : drug.dosageInfo['dosage_form'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          //
          // Admin Route
          //
          drug.drugType == 'DIN'
              ? ListTile(
                  title: const Text('Administration Route'),
                  subtitle: Text(
                    drug.dosageInfo['route'][0]['route_of_administration_name'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              : const SizedBox(width: 0, height: 0),
          //
          // Active Ingredient
          //
          ingCount == 0
              ? const SizedBox(width: 0, height: 0)
              : ListTile(
                  title: drug.drugType == 'DIN'
                      ? const Text('Active Ingredients')
                      : const Text('Medicinal Ingredients'),
                  subtitle: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: ingCount,
                    itemBuilder: buildIngredientTile,
                  ),
                ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(drug.drugName.split("(")[0]),
        actions: [
          TextButton.icon(
            onPressed: () async {
              drugBloc.delete(drug);
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            label: const Text('Delete'),
          )
        ],
      ),
      body: buildDrugDetails(),
    );
  }
}
