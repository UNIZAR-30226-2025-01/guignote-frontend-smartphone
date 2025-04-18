import 'package:flutter/material.dart';
import 'package:sota_caballo_rey/src/utils/validator.dart';
import 'package:sota_caballo_rey/src/widgets/background.dart'; 
import 'package:sota_caballo_rey/src/widgets/corner_decoration.dart';
import 'package:sota_caballo_rey/src/widgets/custom_textform.dart';
import 'package:sota_caballo_rey/src/widgets/custom_title.dart';
import 'package:sota_caballo_rey/src/widgets/custom_button.dart';
import 'package:sota_caballo_rey/src/themes/theme.dart';


class ChangePasswordScreen extends StatefulWidget
{
  const ChangePasswordScreen({super.key});


  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();

}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
{
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;


  void _submitChanges() async
  {
    final form = _formKey.currentState!;
    if(!form.validate()) return;
    form.save();

    // TODO LLAMAR A BACKEND PARA CAMBIAR LA CONTRASEÑA
    // final success = await ApiService().changePassword(_currentPassword, _newPassword);
    // if(!success) {mostrar error respuesta del backend}

    ScaffoldMessenger.of(context).showSnackBar
    (
      const SnackBar
      (
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        backgroundColor: AppTheme.blackColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        duration: Duration(seconds: 2),

        content: Row
        (
          children:
          [
            Icon(Icons.check_circle, color: Colors.amber, size: 24),
            SizedBox(width: 12),

            Expanded
            (
              child: Text
              (
                'Contraseña cambiada correctamente',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );

    // Tiempo de espera para que el usuario vea el mensaje

  }

  @override
  void dispose()
  {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

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
                child: Form
                (
                  key: _formKey,
                  child: Column
                  (
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    [
                      const CustomTitle(title: 'Cambiar contraseña'),

                      const SizedBox(height: 20),

                      CustomTextForm
                      (
                        hintText: 'Contraseña actual',
                        controller: _currentCtrl,
                        obscureText: _hideCurrentPassword,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese su contraseña actual' : null,
                        suffixIcon: IconButton
                        (
                          icon: Icon(_hideCurrentPassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.blackColor),
                          onPressed: () => setState(() => _hideCurrentPassword = !_hideCurrentPassword),
                        ),
                      ),

                      const SizedBox(height: 16),

                      CustomTextForm
                      (
                        hintText: 'Nueva contraseña',
                        controller: _newCtrl,
                        obscureText: _hideNewPassword,
                        validator: (value) => validatePassword(value ?? ''),
                        suffixIcon: IconButton
                        (
                          icon: Icon(_hideNewPassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.blackColor),
                          onPressed: () => setState(() => _hideNewPassword = !_hideNewPassword),
                        ),
                      ),

                      const SizedBox(height: 16),

                      CustomTextForm
                      (
                        hintText: 'Confirmar nueva contraseña',
                        controller: _confirmCtrl,
                        obscureText: _hideConfirmPassword,
                        validator: (value)
                        {
                          if(value == null || value.isEmpty) return 'Confirme su nueva contraseña';
                          if(value != _newCtrl.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                        suffixIcon: IconButton
                        (
                          icon: Icon(_hideConfirmPassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.blackColor),
                          onPressed: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
                        ),
                      ),

                      const SizedBox(height: 30),

                      CustomButton
                      (
                        buttonText: 'Cambiar contraseña',
                        onPressedAction: _submitChanges,
                        color: Colors.grey.shade400,
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