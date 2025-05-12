import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';

class FriendRequestScreen extends StatefulWidget {
  // Para tests: solicitudes precargadas.
  final List<Map<String, String>>? initialRequests;
  final Future<void> Function(String id, bool accept) onManage;

  /// Constructor de clase
  const FriendRequestScreen({super.key, this.initialRequests, Future<void> Function(String, bool)? onManage}) : onManage = onManage ?? _defaultManage;

  static Future<void> _defaultManage(String id, bool accept)
  {
    return accept ? aceptarSolicitudAmistad(id) : denegarSolicitudAmistad(id);
  }

  @override
  FriendRequestState createState() => FriendRequestState();
}

class FriendRequestState extends State<FriendRequestScreen> {
  /// Lista de solicitudes
  List<Map<String, String>> _solicitudes = [];
  /// Indica si la petición a la API continúa en ejecución
  bool _cargando = true;
  /// Indica si se ha producido algún error en la petición
  bool _error = false;

  /// Para animaciones
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.initialRequests != null)
    {
      _solicitudes = widget.initialRequests!;
      _cargando = false;
    }
    else
    {
      _cargarSolicitudes();
    }
  }

  ///
  /// Función que permite obtener listado de solicitudes de amistad
  ///
  Future<void> _cargarSolicitudes() async {
    try {
      List<Map<String, String>> solicitudes = await listarSolicitudesAmistad();
      setState(() {
        _solicitudes = solicitudes;
        _cargando = false;
      });
    } catch(e) {
      setState(() {
        _error = true;
        _cargando = false;
      });
    }
  }

  ///
  /// Aceptar/Denegar solicitud
  ///
  void _gestionSolicitud(int index, bool aceptar, String idSolicitud) async {
    try {
      await widget.onManage(idSolicitud, aceptar);

      _animatedListKey.currentState!.removeItem(
        index, (context, animation) => _itemLista(_solicitudes[index], index, animation),
        duration: const Duration(milliseconds: 250),
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        if(mounted) {
          setState(() {
            _solicitudes.removeAt(index);
          });
        }
      });
    } catch(e) {
      if(mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  ///
  /// Vista principal
  ///
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CustomTitle(title: "Peticiones de amistad"),
          const SizedBox(height: 16),
          if(_cargando)
            const Center(child: CircularProgressIndicator()),
          if(_error)
            Text("Se ha producido un error"),
          if(!_cargando && !_error)
            _lista()
        ],
      );
  }

  ///
  /// Subcomponente: Lista
  ///
  Widget _lista() {
    return Expanded(
      child: _solicitudes.isEmpty
          ? const Center(
          child: Text("No tienes solicitudes pendientes"))
          : AnimatedList(
            key: _animatedListKey,
            initialItemCount: _solicitudes.length,
            itemBuilder: (context, index, animation) {
              return _itemLista(_solicitudes[index], index, animation);
            }
          )
    );
  }

  ///
  /// Subcomponente: Item de la lista
  ///
  Widget _itemLista(Map<String, String> solicitud, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _solicitud(index, solicitud["id"]!, solicitud["solicitante"]!),
    );
  }

  /// Subcomponente: Contenido del ítem de la lista.
  /// Muestra el nombre del emisor de la petición de amistad y dos botones,
  /// uno para aceptar la petición y otro para denegarla.
  Widget _solicitud(int index, String idSolicitud, String nombreEmisor) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.5),
          borderRadius: BorderRadius.circular(12)
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: 64, width: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color(0xFFD72638),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12)
                  )
              ),
              child: IconButton(
                  onPressed: () { _gestionSolicitud(index, false, idSolicitud); },
                  icon: const Icon(Icons.close, color: Colors.white, size: 32))
          ),
          Expanded(child: Text(
            nombreEmisor,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center
          )),
          Container(
            height: 64, width: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFF227C9D),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12)
                )
            ),
            child: IconButton(
              onPressed: () { _gestionSolicitud(index, true, idSolicitud); },
              icon: const Icon(Icons.check, color: Colors.white, size: 32))
          ),
        ]
      )
    );
  }
}