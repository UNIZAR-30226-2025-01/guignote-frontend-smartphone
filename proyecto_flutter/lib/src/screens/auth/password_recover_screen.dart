import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/utils/validator.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart'; 
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_textform.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';


class PasswordRecoverScreen extends StatefulWidget
{
  const PasswordRecoverScreen({super.key});

  @override
  State<PasswordRecoverScreen> createState() => _PasswordRecoverScreenState();

}

class _PasswordRecoverScreenState extends State<PasswordRecoverScreen>
{
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose()
  {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() async
  {
    if(_formKey.currentState!.validate())
    {
      setState(() => _emailSent = true);

      ScaffoldMessenger.of(context).showSnackBar
      (
        const SnackBar
        (
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          backgroundColor: AppTheme.blackColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          duration: Duration(seconds: 3),

          content: Row
          (
            children:
            [
              Icon(Icons.check_circle, color: Colors.amber, size: 24),
              SizedBox(width: 12),

              Expanded
              (
                child: Text('Email enviado', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
     resizeToAvoidBottomInset: false,
     backgroundColor: Colors.transparent,

     body: Stack
     (
      children: 
      [
        const Background(),
        const CornerDecoration(imageAsset: 'assets/images/gold_ornaments.png'),

        Positioned
        (
          top: MediaQuery.of(context).padding.top + 30,
          left: 10,
          child: IconButton
          (
            icon: const Icon(Icons.arrow_back, color: AppTheme.blackColor, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        Center
        (
          child: Container
          (
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration
            (
              color: AppTheme.blackColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SingleChildScrollView
            (
              child: _emailSent ? Column
              (
                mainAxisSize: MainAxisSize.min,
                children: const 
                [
                  Icon(Icons.mark_email_read_outlined, color: Colors.amber, size: 64),
                  SizedBox(height: 24),
                  Text
                  (
                    'Si el correo introducido coincide con una cuenta registrada, '
                    'se enviará una contraseña temporal para restablecer el acceso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],                
              ) : Form
              (
                key: _formKey,
                child: Column
                (
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                    const CustomTitle(title: 'Recuperar contraseña'),
                    const SizedBox(height: 20),

                    CustomTextForm
                    (
                      hintText: 'Introduzca su email',
                      controller: _emailCtrl,
                      suffixIcon: Icon(Icons.email, color: AppTheme.blackColor),
                      validator: (value) => validateEmail(value ?? ''),
                    ),
                    const SizedBox(height: 20),
                    
                    CustomButton
                    (
                      buttonText: 'Enviar',
                      onPressedAction: _submit,
                      color: AppTheme.buttonBackgroundColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
     ),
    );
  }
}