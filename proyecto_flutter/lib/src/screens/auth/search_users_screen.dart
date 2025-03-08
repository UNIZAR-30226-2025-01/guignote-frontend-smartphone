import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';


class SearchUsersScreen extends StatefulWidget {

  /// Constructor de clase
  const SearchUsersScreen({super.key});

  @override
  SearchUsersState createState() => SearchUsersState();
}

class SearchUsersState extends State<SearchUsersScreen> {


  ///
  /// Vista principal
  ///
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          CustomTitle(title: "Buscar usuarios"),
          SizedBox(height: 16),
          buscador()
        ],
      )
    );
  }

  ///
  /// Subcomponente: barra de búsqueda
  ///
  Widget buscador() {
    return SearchBar(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      textStyle: WidgetStateProperty.all(TextStyle(color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold)),
      leading: IconButton(
        icon: const Icon(Icons.search, color: AppTheme.primaryColor),
        onPressed: () {},
      ),
      onChanged: (content) {
        //TODO
      },
    );
  }
}