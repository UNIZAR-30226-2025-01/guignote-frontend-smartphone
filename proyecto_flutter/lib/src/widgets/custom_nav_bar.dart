import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/routes.dart';

class CustomNavBar extends StatelessWidget
{
  final int selectedIndex;

  const CustomNavBar({super.key, required this.selectedIndex});

  /// Método que se ejecuta al pulsar en un elemento del BottomNavigationBar
  /// index: índice del elemento pulsado
  /// 
  /// En este caso, se cambia el índice seleccionado y se navega a la pantalla correspondiente
  /// 
  /// 0: Perfil
  /// 1: Notificaciones
  /// 2: Inicio
  /// 3: Clasificación
  /// 4: Ayuda
  /// 
  /// En cada caso, se navega a la pantalla correspondiente
  /// 
  void _onItemTaped(BuildContext context, int index) 
  {

    switch (index)
    {
      case 0:
        Navigator.pushNamed(context, AppRoutes.profile);
        break;
      
      case 1:
        Navigator.pushNamed(context, AppRoutes.amigos);
        break;

      case 2:
        Navigator.pushNamed(context, AppRoutes.home);
        break;

      case 3:
        Navigator.pushNamed(context, AppRoutes.listGames);
        break;
      
      case 4:
        Navigator.pushNamed(context, AppRoutes.ranking);
        break;
      
      default:
        break;
    }
  }

  @override
  BottomNavigationBar build(BuildContext context)
  {
    return BottomNavigationBar
      (
        items: const <BottomNavigationBarItem>
        [
          
          BottomNavigationBarItem
          (
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
                    
          BottomNavigationBarItem
          (
            icon: Icon(Icons.import_contacts_outlined),
            label: 'Amigos',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.home), 
            label: 'Inicio',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.dns),
            label: 'Partidas',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.emoji_events),
            label: 'Clasificación',
          ),

        ],

        
        currentIndex: selectedIndex, // Índice del elemento seleccionado
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.blackColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onItemTaped(context, index),
      );
  }
  
}

