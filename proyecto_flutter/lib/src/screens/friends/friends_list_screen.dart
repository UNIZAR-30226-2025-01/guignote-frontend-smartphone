import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/friends/friend_chat.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';

class FriendsListScreen extends StatefulWidget {

  /// Constructor de clase
  const FriendsListScreen({super.key});

  @override
  FriendsListState createState() => FriendsListState();
}

class FriendsListState extends State<FriendsListScreen> {
  /// Lista de amigos con nombres e ids
  List<Map<String, String>> _amigos = [];
  /// Indica si la petición a la API continúa en ejecución
  bool _cargando = true;
  /// Indica si se ha producido algún error en la petición
  bool _error = false;

  /// Para animaciones
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cargarAmigos();
  }

  ///
  /// Función que permite obtener el listado de amigos
  /// del usuario.
  ///
  Future<void> _cargarAmigos() async {
    try {
      List<Map<String, String>> amigos = await obtenerAmigos();
      setState(() {
        _amigos = amigos;
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
  /// Función que permite eliminar de la lista de amigos
  /// del usuario al usuario identificado por 'id'
  ///
  void _eliminarAmigo(int index, String id) async {
    try {
      await eliminarAmigo(id);

      _animatedListKey.currentState!.removeItem(
        index, (context, animation) => _itemLista(_amigos[index], index, animation),
        duration: const Duration(milliseconds: 250),
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        if(mounted) {
          setState(() {
            _amigos.removeAt(index);
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
            CustomTitle(title: "Amigos"),
            SizedBox(height: 16),
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
        child: _amigos.isEmpty
            ? const Center(
            child: Text("No tienes amigos"))
            : AnimatedList(
                key: _animatedListKey,
                initialItemCount: _amigos.length,
                itemBuilder: (context, index, animation) {
                  return _itemLista(_amigos[index], index, animation);
                }
              )
    );
  }

  ///
  /// Subcomponente: Item de la lista
  ///
  Widget _itemLista(Map<String, String> amigo, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _amigo(index, amigo["id"]!, amigo["nombre"]!),
    );
  }

  ///
  /// Subcomponente: Contenido del item de la lista.
  /// Muestra la inicial del nombre del amigo, el nombre y
  /// un botón para eliminar a dicho amigo.
  ///
  Widget _amigo(int index, String id, String nombre) {
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
            height: 64,
            width: 64,
            decoration: BoxDecoration(
                color: Color.fromRGBO(190, 95, 5, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12)
                )
            ),
            alignment: Alignment.center,
            child: Text(
                nombre[0],
                style: const TextStyle(fontSize: 32,
                    fontWeight: FontWeight.bold)
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendChat(receptorId: id, receptorNom: nombre),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  nombre,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => { _eliminarAmigo(index, id) }
          )
        ]
      )
    );
  }
}