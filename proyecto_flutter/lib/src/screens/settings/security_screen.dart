///
///
///
///
///
library;

import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/settings_tile_data.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/routes.dart';
import 'package:sota_caballo_rey/src/services/api_service.dart';
import 'package:sota_caballo_rey/src/services/audio_service.dart';

class SecurityScreen extends StatelessWidget
{
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    final tiles = <SettingsTileData>
    [
      SettingsTileData
      (
        icon: Icons.lock,
        title: 'Cambiar contraseña',
        onTap: () 
        {
          // Acción al pulsar la opción
          Navigator.pushNamed(context, AppRoutes.changePassword); // Navegamos a la pantalla de cambio de contraseña
        },
      ),
      SettingsTileData
      (
        icon: Icons.delete_forever,
        title: 'Eliminar cuenta',
        onTap: () => _confirmDelete(context), // Acción al pulsar la opción
      ),
      SettingsTileData
      (
        icon: Icons.privacy_tip,
        title: 'Política de privacidad',
        onTap: () 
        {
          // Acción al pulsar la opción
          Navigator.pushNamed(context, AppRoutes.privacity); // Navegamos a la pantalla de política de privacidad

        },
      ),
      SettingsTileData
      (
        icon: Icons.info_outline,
        title: 'Qué datos recopilamos',
        onTap: () 
        {
          // Acción al pulsar la opción
          Navigator.pushNamed(context, AppRoutes.dataPolicy); // Navegamos a la pantalla de política de datos
        },
      ),
    ]; // Lista de datos de los tiles
    return Scaffold
    (
      backgroundColor: Colors.transparent,
      body: Stack
      (
        children: 
        [
          const Background(), // Fondo de la pantalla
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'), // Decoración de las esquinas

           Positioned
          (
            top: MediaQuery.of(context).padding.top + 30,
            left: 10,
            child: IconButton
            (
              icon: const Icon(Icons.arrow_back, color: AppTheme.blackColor, size: 30),
              onPressed: () => Navigator.of(context).pop(), // Cierra la pantalla actual
            ),
          ),

          Center
          (
            child: Container
            (
              margin: const EdgeInsets.symmetric(horizontal: 16), // Margen horizontal
              padding: const EdgeInsets.all(20), // Espaciado interno
              decoration: BoxDecoration
              (
                color: AppTheme.blackColor, // Color de fondo
                borderRadius: BorderRadius.circular(15), // Bordes redondeados
              ),
              child: Column
              (
                mainAxisSize: MainAxisSize.min,
                children: 
                [
                  Text('Seguridad y privacidad', style: AppTheme.titleTextStyle), // Título de la sección

                  const SizedBox(height: 20), // Espaciado

                  ListView.separated
                  (
                    shrinkWrap: true, // Reduce el tamaño de la lista
                    primary: false, // Desactiva el desplazamiento primario
                    itemCount: tiles.length, // Número de elementos en la lista
                    separatorBuilder: (context, index) => const SizedBox(height: 12), // Separador entre elementos
                    itemBuilder: (context, index)
                    {
                      final t = tiles[index]; // Obtenemos el tile actual
                      return Card
                      (
                        color: Colors.white.withAlpha(20), // Color de fondo del tile
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bordes redondeados
                        elevation: 0, // Elevación del tile
                        child: ListTile
                        (
                          leading: Icon(t.icon, color: Colors.white), // Icono del tile
                          title: Text(t.title, style: const TextStyle(color: Colors.white)), // Título del tile
                          trailing: const Icon(Icons.chevron_right, color: Colors.white), // Icono de flecha
                          onTap: t.onTap, // Acción al pulsar el tile
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Espaciado interno del tile
                        ),
                      ); // Tarjeta para el tile
                    },
                  ),
                ],
              ),
            ),
          ),

          
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext screenContext) 
  {
    showDialog<bool>
    (
      context: screenContext,
      builder: (context) => Dialog
      (
        backgroundColor: AppTheme.blackColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Bordes redondeados

        child: Padding
        (
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Espaciado interno

          child: Column
          (
            mainAxisSize: MainAxisSize.min, // Tamaño mínimo de la columna
            mainAxisAlignment: MainAxisAlignment.center, // Alineación vertical

            children: 
            [
              Text
              (
                'Eliminar cuenta',
                style: const TextStyle(color: Colors.white, fontSize: 24), // Estilo del texto
              ),
              const SizedBox(height: 12), // Espaciado

              const Text
              (
                '¿Estás seguro de que quieres eliminar tu cuenta? '
                  'Esta acción no se puede deshacer.',
                textAlign: TextAlign.center, // Alineación del texto
                style: TextStyle(color: Colors.white70, fontSize: 16), // Estilo del texto
              ),
              const SizedBox(height: 24), // Espaciado

              Row
              (
                children:
                [
                  Expanded // Expande el widget para ocupar todo el espacio disponible
                  (
                    child: TextButton // Botón de texto
                    (
                      onPressed: () => Navigator.of(context).pop(false), // Acción al pulsar el botón
                     style: TextButton.styleFrom(foregroundColor: Colors.white70), // Estilo del texto
                      child: const Text('Cancelar'), // Texto del botón
                    ),
                  ),
                  const SizedBox(width: 12), // Espaciado

                  Expanded // Expande el widget para ocupar todo el espacio disponible
                  (
                    child: ElevatedButton
                    (
                      onPressed: () async
                      {
                        Navigator.of(context).pop(); // Cierra el diálogo y devuelve true

                        // Se muestra un spinner mientras se procesa la eliminación de la cuenta
                        showDialog
                        (
                          context: context,
                          barrierDismissible: false, // No se puede cerrar el diálogo al tocar fuera de él
                          builder: (context) => const Center // Centra el spinner en la pantalla
                          (
                            child: CircularProgressIndicator(), // Spinner de carga
                          ),
                        );

                        try
                        {
                          await AudioService().stopMusic(); // Detiene la música de fondo
                          await deleteUser(); // Llama a la función para eliminar la cuenta

                          Navigator.of(screenContext).pop(); // Cierra el diálogo de carga

                          //  redirige a la pantalla de inicio de bienvenida y limpiamos rutas
                          Navigator.pushNamedAndRemoveUntil(screenContext, AppRoutes.welcome, (route) => false); // Navega a la pantalla de bienvenida
                        } on Exception catch (e)
                        {
                          Navigator.of(screenContext).pop(); // Cierra el diálogo de carga

                          final msg = e.toString().contains('token')
                            ? 'No se puede eliminar la cuenta. Por favor, cierra sesión e inténtalo de nuevo.'
                            : 'Error al eliminar la cuenta. Por favor, inténtalo de nuevo.'; // Mensaje de error

                          ScaffoldMessenger.of(screenContext).showSnackBar
                          (
                            SnackBar
                            (
                              content: Text(msg), // Mensaje de error
                              backgroundColor: Colors.redAccent, // Color de fondo del snackbar
                              behavior: SnackBarBehavior.floating, // Comportamiento del snackbar
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom
                      (
                        backgroundColor: Colors.redAccent, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0, // Elevación del botón
                      ), // Estilo del botón
                      child: const Text('Eliminar cuenta', style: TextStyle(color: Colors.white)), // Texto del botón
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}