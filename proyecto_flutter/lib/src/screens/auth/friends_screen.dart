
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/screens/auth/friend_request_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/friends_list_screen.dart';
import 'package:sota_caballo_rey/src/screens/auth/search_users_screen.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  FriendsScreenState createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  int _pantallaSeleccionada = 0;

  // Lista de pantallas de gestión de amigos
  final List<Widget> _pantallas = [
    FriendsListScreen(),
    FriendRequestScreen(),
    SearchUsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Expanded(child: _pantallas[_pantallaSeleccionada])
                  ],
                )
            )
          )
        ],
      )
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