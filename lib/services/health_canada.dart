import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/drug.dart';

class DpdApiService {
  // DpdApiService._internal();
  // static final DpdApiService _instance = DpdApiService._internal();
  // factory DpdApiService() {
  //   return _instance;
  // }

  static const _apiHost = 'health-products.canada.ca';

  static String _getApiPath(String field) {
    return '/api/drug/$field';
  }

  static Future<List<dynamic>?> searchProducts(Map query) async {
    return await _callRestApi(_getApiPath('drugProduct'), query);
  }

  static Future<List<dynamic>?> getProductInfo(Drug drug, String field) async {
    return await _callRestApi(
        _getApiPath(field), {'id': drug.drugInfo['drug_code'].toString()});
  }

  static Future<List<dynamic>?> _callRestApi(String apiPath, Map query) async {
    final url = Uri(
      scheme: 'https',
      host: _apiHost,
      path: apiPath,
      queryParameters: {
        'lang': 'en',
        'type': 'json',
        ...query,
      },
    );

    debugPrint('url: $url');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      debugPrint('server responded: ${res.statusCode}');
      return null;
    }

    try {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body;
      } else {
        return [body];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}

class LnhpdApiService {
  // LnhpdApiService._internal();
  // static final LnhpdApiService _instance = LnhpdApiService._internal();
  // factory LnhpdApiService() {
  //   return _instance;
  // }

  static const _apiHost = 'health-products.canada.ca';

  static String _getApiPath(String field) {
    return '/api/natural-licences/$field';
  }

  static Future<List<dynamic>?> searchProducts(Map query) async {
    return await _callRestApi(_getApiPath('productlicence'), query);
  }

  static Future<List<dynamic>?> getProductInfo(Drug drug, String field) async {
    return await _callRestApi(_getApiPath(field), {'id': drug.drugId});
  }

  static Future<List<dynamic>?> _callRestApi(String apiPath, Map query) async {
    final url = Uri(
      scheme: 'https',
      host: _apiHost,
      path: apiPath,
      queryParameters: {
        'lang': 'en',
        'type': 'json',
        ...query,
      },
    );

    debugPrint('url: $url');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      debugPrint('server responded: ${res.statusCode}');
      return null;
    }

    try {
      final body = jsonDecode(res.body);
      if (body is List) {
        return body;
      } else {
        return [body];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}
