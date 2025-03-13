import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';


class SearchUsersScreen extends StatefulWidget {

  /// Constructor de clase
  const SearchUsersScreen({super.key});

  @override
  SearchUsersState createState() => SearchUsersState();
}

class SearchUsersState extends State<SearchUsersScreen> {
  /// Lista de usuarios cuyo nombre contiene texto del buscador
  List<Map<String, String>> _usuarios = [];
  /// Indica si la petición a la API continúa en ejecución
  bool _cargando = false;
  /// Indica si se ha producido algún error en la petición
  bool _error = false;
  /// Contenido barra búsqueda
  String contenido = "";

  /// Para animaciones
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  ///
  /// Función que permite obtener el listado de usuarios cuyo
  /// nombre contiene el texto introducido en el buscador
  ///
  Future<void> _cargarUsuarios(String prefijo) async {
    setState(() {
      _cargando = true;
    });
    try {
      List<Map<String, String>> usuarios = await buscarUsuarios(prefijo);
      setState(() {
        _usuarios = usuarios;
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
  /// Función que permite enviar una solicitud al usuario
  /// identificado por 'id'
  ///
  void _enviarSolicitud(int index, String id) async {
    try {
      await enviarSolicitud(id);

      _animatedListKey.currentState!.removeItem(
        index, (context, animation) => _itemLista(_usuarios[index], index, animation),
        duration: const Duration(milliseconds: 250),
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        if(mounted) {
         setState(() {
           _usuarios.removeAt(index);
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
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const CustomTitle(title: "Buscar usuarios"),
          const SizedBox(height: 16),
          _buscador(),
          const SizedBox(height: 16),
          if(_cargando)
            const Center(child: CircularProgressIndicator()),
          if(_error)
            Text("Se ha producido un error"),
          if(!_cargando && !_error)
            _lista()
        ],
      )
    );
  }

  ///
  /// Subcomponente: Lista animada
  ///
  Widget _lista() {
    return Expanded(
      child: _usuarios.isEmpty
          ? const Center(
          child: Text("Sin resultados"))
          : AnimatedList(
            key: _animatedListKey,
            initialItemCount: _usuarios.length,
            itemBuilder: (context, index, animation) {
              return _itemLista(_usuarios[index], index, animation);
            },
          )
    );
  }

  ///
  /// Subcompoente: Item de la lista
  ///
  Widget _itemLista(Map<String, String> usuario, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _usuario(index, usuario["id"]!, usuario["nombre"]!),
    );
  }

  /// Subcomponente: Contenido del ítem de la lista.
  /// Muestra un icono decorativo, el nombre del amigo y un botón
  /// para enviarle solicitud de amistad.
  Widget _usuario(int index, String id, String nombre) {
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
            child: Text(
              nombre[0],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
            )
          ),
          Expanded(child: Text(
            nombre,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center
          )),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromRGBO(190, 95, 5, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
              ),
              child: const Text(
                  "Enviar solicitud",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
              ),
              onPressed: () {
                _enviarSolicitud(index, id);
              },
            ),
          )
        ]
      )
    );
  }

  ///
  /// Subcomponente: barra de búsqueda
  ///
  Widget _buscador() {
    return SearchBar(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      textStyle: WidgetStateProperty.all(TextStyle(color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold)),
      trailing: [IconButton(
        icon: const Icon(Icons.search, color: AppTheme.primaryColor),
        onPressed: () {
          if(contenido.isEmpty) {
            setState(() {
              _usuarios.clear();
            });
          } else {
            _cargarUsuarios(contenido);
          }
        },
      )],
      onChanged: (content) { contenido = content.trim(); },
    );
  }
}