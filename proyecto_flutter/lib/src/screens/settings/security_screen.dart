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

          SafeArea
          (
            child: Padding
            (
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Espaciado interno
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text
                  (
                    'Seguridad y privacidad',
                    style: AppTheme.titleTextStyle, // Estilo del texto
                  ),
                  const SizedBox(height: 24), // Espaciado

                  Expanded
                  (
                    child: ListView.separated // Lista separada
                    (
                      itemCount: tiles.length, // Número de elementos
                      separatorBuilder: (context, index) => const SizedBox(height: 12), // Separador entre elementos
                      itemBuilder: (context, index)
                      {
                        final t = tiles[index]; // Obtenemos el elemento de la lista
                        return Card
                        (
                          color: Colors.white.withAlpha(20), // Color de la tarjeta
                          shape: RoundedRectangleBorder // Forma de la tarjeta
                          (
                            borderRadius: BorderRadius.circular(15), // Bordes redondeados
                          ),
                          elevation: 0, // Elevación de la tarjeta
                          child: ListTile // Elemento de la lista
                          (
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Espaciado interno
                            leading: Icon(t.icon, color: Colors.white), // Icono de la izquierda
                            title: Text(t.title, style: const TextStyle(color: Colors.white)), // Título del elemento
                            trailing: const Icon(Icons.chevron_right, color: Colors.white), // Icono de la derecha
                            onTap: t.onTap, // Acción al pulsar el elemento
                          ),
                        );
                      }, // Elemento de la lista
                    ),
                  ),
                ],
              ),
            ),
          ), // Espacio seguro para el contenido
          
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) 
  {
    showDialog<bool>
    (
      context: context,
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
                      onPressed: () 
                      {
                        // Acción al pulsar el botón
                        Navigator.of(context).pop(true); // Cierra el diálogo y devuelve true
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withAlpha(60), // Color de fondo del botón
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Bordes redondeados
                        minimumSize: const Size.fromHeight(48), // Tamaño mínimo del botón
                        elevation: 0, // Elevación del botón
                      ),
                      child: const Text('Eliminar cuenta', style: TextStyle(color: Colors.white)), // Texto del botón
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed)
    {
      if (confirmed == true) 
      {
        // Acción al confirmar la eliminación de la cuenta
        // TODO ELIMINAR CUENTA?
      }
    });
  }
}