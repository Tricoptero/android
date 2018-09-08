class PlanificacionModel {

  final int ano;
  final int semana;
  final int idCompromiso;
  final Duration duracion;
  final int periodicidad;
  final String comentario;
  final int stamp;

  PlanificacionModel (this.ano, this.semana, this.idCompromiso,
      {this.duracion, this.periodicidad, this.comentario, this.stamp} );

  PlanificacionModel.fromDb(Map<String, dynamic>  parsedJson)
      : ano = parsedJson['ano'],
        semana = parsedJson['semana'],
        idCompromiso =parsedJson['id_compromiso'],
        comentario =parsedJson['comentario'],
        periodicidad =parsedJson['periodicidad'],
        duracion = Duration(minutes: parsedJson["duracion"]),
        stamp = parsedJson['stamp'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "ano":ano,
      "semana":semana,
      "id_compromiso": idCompromiso,
      "comentario": comentario,
      "duracion": duracion.inMinutes,
      "periodicidad": periodicidad,
      "stamp": stamp,
    };}

}