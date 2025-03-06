import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';

class HomeScreen extends StatefulWidget 
{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> 
{
  final String? profileImageUrl = 'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png';
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  final List<String> _gameModes = 
  [
    'assets/images/AsOros.png',
    'assets/images/2Oros.png',
  ];

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.transparent,
      body: Stack
      (
        children:
        [
          const Background(),
          const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),
          
          Column
          (
            children: 
            [
              AppBar
              (
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row
                (
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: 
                  [
                    profileButton(context),
                    Image.asset('assets/images/app_logo_white.png', width: 60, height: 60),
                    IconButton
                    (
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () 
                      {
                        ScaffoldMessenger.of(context).showSnackBar
                        (
                          const SnackBar
                          (
                            content: Text('Configuración', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.black,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                   [
                    CarouselSlider
                    (
                      items: _gameModes.map((mode) 
                      {
                        return Builder
                        (
                          builder: (BuildContext context) 
                          {
                            return GestureDetector
                            (
                              onTap: () 
                              {
                                // Acción al pulsar en la imagen del modo de juego
                                ScaffoldMessenger.of(context).showSnackBar
                                (
                                  SnackBar
                                  (
                                    content: Text('Seleccionado: $mode'),
                                    backgroundColor: Colors.black,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Image.asset(mode, fit: BoxFit.cover, width: 300),
                            );
                          },
                        );
                      }).toList(),
                      
                      carouselController: _carouselController,
                      options: CarouselOptions
                      (
                        height: 400,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) 
                        {
                          setState(() 
                          {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
                    Row
                    (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _gameModes.asMap().entries.map((entry) 
                      {
                        return GestureDetector
                        (
                          onTap: () => _carouselController.animateToPage(entry.key),
                          child: Container
                          (
                            width: 12.0,
                            height: 12.0,
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration
                            (
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Row
                    (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: 
                      [
                        IconButton
                        (
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => _carouselController.previousPage(),
                        ),
                        IconButton
                        (
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () => _carouselController.nextPage(),
                        ),
                      ],
                    ),
                    ElevatedButton
                    (
                      onPressed: ()
                      {
                        // Acción al pulsar en el botón de buscar partida
                        ScaffoldMessenger.of(context).showSnackBar
                        (
                          const SnackBar
                          (
                            content: Text('Buscando partida...'),
                            backgroundColor: Colors.black,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text('Buscar Partida'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar
      (
        items: const <BottomNavigationBarItem>
        [
          BottomNavigationBarItem
          (
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],

        currentIndex: 0, // Índice del elemento seleccionado
        selectedItemColor: Colors.amber[800],
        onTap: (index) 
        {
          // Acción al pulsar en un elemento del BottomNavigationBar
        },
      ),
    );
  }

  Widget profileButton(BuildContext context) 
  {
    return Padding
    (
      padding: const EdgeInsets.only(left: 10.0),
      child: GestureDetector
      (
        onTap: () 
        {
          ScaffoldMessenger.of(context).showSnackBar
          (
            const SnackBar
            (
              content: Text('¡Hola!', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: CircleAvatar
        (
          radius: 20,
          backgroundColor: Colors.transparent,
          backgroundImage: profileImageUrl != null
              ? NetworkImage(profileImageUrl!)
              : const AssetImage('assets/images/default_profile.png') as ImageProvider,
          child: profileImageUrl == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}