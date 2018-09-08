class RegistroModel {

  final DateTime fecha;
  final int idCompromiso;
  final int cumplimiento;

  final int stamp;

  RegistroModel (this.fecha, this.idCompromiso, this.cumplimiento, this.stamp);

  RegistroModel.fromDb(Map<String, dynamic>  parsedJson)
      : fecha = DateTime.fromMillisecondsSinceEpoch(parsedJson['fecha']),
        idCompromiso =parsedJson['id_compromiso'],
        cumplimiento =parsedJson['cumplimiento'],
        stamp = parsedJson['stamp'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "fecha": fecha.millisecondsSinceEpoch,
      "id_compromiso": idCompromiso,
      "cumplimiento": cumplimiento,
      "stamp": stamp,
    };}

}