import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart';
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';

class HomeScreen extends StatefulWidget 
{
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> 
{
  final String? profileImageUrl = 'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png';
  int _currentIndex = 0;
  int _selectedIndex = 2; // índice inicial para la pantalla de inicio 

  final _pageController = PageController();

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
  void _onItemTaped(int index) 
  {
    setState(() 
    {
      _selectedIndex = index;
    });

    switch (index)
    {
      case 0:
        Navigator.pushNamed(context, '/profile');
        break;
      
      case 1:
        Navigator.pushNamed(context, '/notifications');
        break;

      case 2:
        Navigator.pushNamed(context, '/home');
        break;

      case 3:
        Navigator.pushNamed(context, '/ranking');
        break;
      
      case 4:
        Navigator.pushNamed(context, '/help');
        break;
      
      default:
        break;
    }
  }



  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
    appBar:AppBar
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
              const SizedBox(height: 20),
              Expanded
              (
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                   [

                    SizedBox
                    (
                      height: 500,
                      child:  PageView
                      (
                        controller: _pageController,
                        children: 
                        [
                          _buildGameModeCard('Modo 2vs2', 'assets/images/cartasBoton.png', 'Juega en equipos de dos.'),
                          _buildGameModeCard('Modo 1vs1', 'assets/images/cartaBoton.png', 'Desafía a un solo oponente.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    SmoothPageIndicator
                    (
                      controller: _pageController,
                      count: 2,
                      effect: WormEffect
                      (
                        dotHeight: 10,
                        dotWidth: 10,
                        activeDotColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    _buildPlayButton(),
                    
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
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
                    
          BottomNavigationBarItem
          (
            icon: Icon(Icons.inbox),
            label: 'Notificaciones',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.home), 
            label: 'Inicio',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.emoji_events),
            label: 'Clasificación',
          ),

          BottomNavigationBarItem
          (
            icon: Icon(Icons.help),
            label: 'Ayuda',
          ),
        ],

        
        currentIndex: _selectedIndex, // Índice del elemento seleccionado
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        backgroundColor: AppTheme.blackColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTaped,
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

  Widget _buildGameModeCard(String title, String assetPath, String description)
  {
    return Padding
    (
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card
      (
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,

        child: Stack
        (
          children: 
          [
            Container
            (
              decoration: BoxDecoration
              (
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage
                (
                  image: AssetImage(assetPath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                ),
              ),
            ),

            Container
            (
              decoration: BoxDecoration
              (
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient
                (
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Padding
            (
              padding: const EdgeInsets.all(16.0),
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text
                  (
                    title, 
                    style: const TextStyle
                    (
                      color: Colors.white, 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      shadows: 
                      [
                        Shadow
                        (
                          offset: Offset(2, 2),
                          blurRadius: 3.0,
                          color: AppTheme.blackColor,
                        )
                      ],
                    )
                  ),
                  const SizedBox(height: 8),
                  Text
                  (
                    description,
                    style: TextStyle
                    (
                      fontSize: 16,
                      color: Colors.white70,
                      shadows:
                      [
                        Shadow
                        (
                          offset: Offset(1, 1),
                          blurRadius: 2.0,
                          color: AppTheme.blackColor,
                        ),
                      ]

                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton()
  {
    return GestureDetector
    (
      key: const Key('play_button'),
      onTap: ()
      {
        ScaffoldMessenger.of(context).showSnackBar
        (
          const SnackBar
          (
            content: Text('¡A jugar!'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      },

      child: AnimatedContainer
      (
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(1.05, 1.05, 1),
        child: CustomButton(buttonText: 'Buscar Partida', onPressedAction:(){}, color: Colors.amber),
      ),
    );
  }
}