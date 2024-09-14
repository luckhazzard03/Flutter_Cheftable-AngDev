import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart'; // Generado automáticamente por build_runner

@JsonSerializable()
class Order {
  @JsonKey(name: 'Comanda_id')
  int? id;

  String? fecha;
  String? hora;
  @JsonKey(name: 'Total_platos')
  int? totalPlatos;
  @JsonKey(name: 'Precio_Total')
  double? precioTotal;
  @JsonKey(name: 'Tipo_Menu')
  String? tipoMenu;
  @JsonKey(name: 'idUsuario_fk')
  int? idUsuarioFk;
  @JsonKey(name: 'idMesa_fk')
  int? idMesaFk;
  @JsonKey(name: 'create_at')
  String? createAt;
  @JsonKey(name: 'update_at')
  String? updateAt;

  Order({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.totalPlatos,
    required this.precioTotal,
    required this.tipoMenu,
    required this.idUsuarioFk,
    required this.idMesaFk,
    required this.createAt,
    required this.updateAt,
  });

  // Convierta un JSON a una instancia de Order
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  // Convierta una instancia de Order a JSON
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
