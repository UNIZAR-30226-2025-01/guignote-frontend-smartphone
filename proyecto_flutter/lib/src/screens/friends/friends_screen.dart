
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/friends/friend_request_screen.dart';
import 'package:sota_caballo_rey/src/screens/friends/friends_list_screen.dart';
import 'package:sota_caballo_rey/src/screens/friends/search_users_screen.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_nav_bar.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  FriendsScreenState createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  int _pantallaSeleccionada = 0;



  @override
  Widget build(BuildContext context) 
  {
    // Definimos la lista de pantallas para poder usar el contexto
    final pantallas = <Widget>
    [
      const FriendsListScreen(),
      const FriendRequestScreen(),
      SearchUsersScreen
      (
        onSend: (String id) async 
        {
          // Llama a tu ApiService
          await enviarSolicitud(id);
          // Muestra resultado
          if (!mounted) return;

        },
      ),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  children: [
                    menu(),
                    SizedBox(height: 32),
                    Expanded(child: pantallas[_pantallaSeleccionada])
                  ],
                )
            )
          )
        ],
      ),
      bottomNavigationBar: CustomNavBar(selectedIndex: 1),
    );
  }

  Widget menu() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        button(0, "Amigos"),
        button(1, "Solicitudes"),
        button(2, "Buscar")
      ],
    );
  }

  Widget button(int indice, String texto) {
    bool isSelected = _pantallaSeleccionada == indice;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _pantallaSeleccionada = indice;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Color.fromRGBO(0, 0, 0, 0.5): Colors.transparent,
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            ),
          ),
        )
      )
    );
  }
}