class CompromisoModel {

  int idCompromiso;
  String nombre;
  String tipo;
  String comentario;
  Duration duracion;
  int periodicidad;
  bool activo;
  int stamp;

  CompromisoModel(this.idCompromiso, {this.nombre,
  this.tipo,this.comentario,this.duracion,this.periodicidad,this.activo, this.stamp});

  CompromisoModel.fromJson (Map<String, dynamic> parsedJson):
      idCompromiso=parsedJson['id_compromiso'],
      nombre = parsedJson['nombre'],
      tipo = parsedJson['tipo'],
      comentario = parsedJson['comentario'] ?? '',
      periodicidad = parsedJson['periodicidad'],
      activo = parsedJson['activo'],
      duracion = Duration(hours: int.parse(parsedJson['horas'] ?? '0'), minutes: int.parse(parsedJson['minutos'] ?? '0')),
      stamp = parsedJson['stamp'] ?? 0;

  CompromisoModel.fromDb(Map<String, dynamic>  parsedJson)
      :idCompromiso =parsedJson['id_compromiso'],
        nombre =parsedJson['nombre'],
        tipo =parsedJson['tipo'],
        comentario =parsedJson['comentario'],
        periodicidad =parsedJson['periodicidad'],
        duracion = Duration(minutes: parsedJson["duracion"]),
        activo = parsedJson['activo'] == 1,
        stamp = parsedJson['stamp'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id_compromiso": idCompromiso,
      "nombre": nombre,
      "tipo": tipo,
      "comentario": comentario,
      "duracion": duracion.inMinutes,
      "periodicidad": periodicidad,
      "activo": activo ? 1 : 0,
      "stamp": stamp,
    };
  }


  @override
  toString() {
    return '[idCompromiso : $idCompromiso, nombre : $nombre, tipo:$tipo, comentario:$comentario, duracion:${duracion.toString()}, periodicidad : $periodicidad, activo:$activo]';
  }
}