import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import '../models/compromiso_model.dart';


final _root = 'http://compromisos-env.k3mgyik3dw.eu-west-1.elasticbeanstalk.com/webservice';


class ApiProvider {



  Client client = Client();
  String token;
  String apiEmail;
  String apiPassword;



  Future<Response> validaUsuario(String email, String password) async {
    Map<String, String> usu = new Map();
    usu["usuario"] = email;
    usu["password"] = password;

    String body = json.encode(usu);

    final response = await client.post('$_root/auth',
      headers: {HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"},
      body: body,
    );

    if (response.statusCode == 201) {
      apiEmail = email;
      apiPassword = password;
      Map<String, dynamic> respuestaJson = new Map();
      respuestaJson = json.decode(response.body);
      token = respuestaJson['token'];
    }
    return response;
  }



  Future<List<CompromisoModel>> fetchCompromisos() async {
    Response response;

    response = await client.get('$_root/compromisos/lista',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": token});

    // en caso de que halla vencido el token volvemos a solicitarlo
    if (response.statusCode == 401) {
      await validaUsuario(apiEmail, apiPassword);
      response = await client.get('$_root/compromisos/lista',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            "Authorization": token});
    }
    String body = utf8.decode(response.bodyBytes);

    Iterable l = json.decode(body);


    List<CompromisoModel> compromisos = new List();
    l.forEach((model) {compromisos.add(CompromisoModel.fromJson(model));});

    return compromisos;
  }


}

final api = ApiProvider();
