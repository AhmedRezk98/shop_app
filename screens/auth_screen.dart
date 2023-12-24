import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
// ignore: constant_identifier_names
enum AuthMode{Signup,Login}
class AuthScreen extends StatelessWidget {
  static const routeName = '/auth-screen';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    const Color.fromRGBO(255, 188, 215, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                   stops: const [0,1],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: SizedBox(
                  width: deviceSize.width,
                  height: deviceSize.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 94),
                        transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade900,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ]
                        ),
                        child: Text('My Shop',style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Anton',
                        )),
                      )),
                      Flexible(
                        flex: deviceSize.width > 600? 2 : 1,
                        child: const AuthCard(),
                      )
                    ],
                  ),
                ),
              )
            ],
        ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _key = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String,String> _authData = {
    'email' : '',
    'password' : '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _animationController;
  Animation<Size>? _animation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Size>(
      begin: const Size(double.infinity, 260),
      end: const Size(double.infinity,320)
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.fastOutSlowIn)
    );
    _opacityAnimation = Tween<double>(begin: 0.0,end: 1.0).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1.5),end: const Offset(0, 0)).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
    //_animation!.addListener(() => setState((){}));
  }
  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }
  void _showErrDialog(String message){
    showDialog(context: context, builder: (ctx)=>AlertDialog(
      content: Text(message),
      title: const Text('an error occured'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(ctx).pop();
        },
          child: const Text('okay'),
        ),
      ],
    ));
  }
  Future<void> _submit() async {
    if(!_key.currentState!.validate()){
      return;
    }
    _key.currentState!.save();
    setState((){
      _isLoading = true;
    });
    try{
      if(_authMode == AuthMode.Login){
        await Provider.of<Auth>(context,listen: false).login(_authData['email'], _authData['password']);
      }
      else{
        await Provider.of<Auth>(context,listen: false).signup(_authData['email'], _authData['password']);
      }
    } on HttpException catch(error){
      var errorMessage = 'Authentication Failed';
      if(error.toString().contains('EMAIL_EXIST')){
        errorMessage = 'the email is already in use';
      }
      else if(error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'the email is invalid';
      }
      else if(error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'the password is too weak';
      }
      else if(error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = 'the email is not found';
      }
        else if(error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'the password is invalid';
      }
      _showErrDialog(errorMessage);
    } catch (error){
      var errorMessage = 'could not authenticate you please try again later';
      _showErrDialog(errorMessage);
    }
    setState((){
      _isLoading = false;
    });

  }
  void _switchAuthMode(){
    if(_authMode == AuthMode.Login){
      setState((){
        _authMode = AuthMode.Signup;
      });
      _animationController!.forward();
    }
    else{
      setState((){
        _authMode = AuthMode.Login;
      });
      _animationController!.reverse();
    }
  }
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authMode==AuthMode.Signup?320:260,
          //height: _animation!.value.height,
          constraints: BoxConstraints(
            minHeight:_authMode==AuthMode.Signup?320:260,
          ),
          width: deviceSize.width * 0.75,
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value){
                      if(value!.isEmpty || !value.contains('@')){
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    onSaved: (value){
                      _authData['email'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value){
                      if(value!.isEmpty || value.length > 5){
                        return 'password is too short';
                      }
                      return null;
                    },
                    onSaved: (value){
                      _authData['password'] = value!;
                    },
                  ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ?60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ?120 : 0,
                      ),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        opacity: _opacityAnimation!,
                        child: SlideTransition(
                          position: _slideAnimation!,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'confirm password',
                            ),
                            obscureText: true,
                            validator: _authMode == AuthMode.Signup ? (value){
                              if(value != _passwordController.text){
                                return 'password do not match';
                              }
                            }: null,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if(_isLoading) const CircularProgressIndicator()
                  else ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 8),
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button!.color,
                      ),
                    ),
                    child: Text(_authMode == AuthMode.Signup? 'Sign Up' : 'Log In'),
                  ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal: 30,vertical: 4)
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: MaterialStateProperty.all<TextStyle>(
                            TextStyle(
                              color: Theme.of(context).primaryColor,))),
                    child: Text('${_authMode == AuthMode.Signup?'Sign Up' : 'Log In'} instead'),
                  ),
                ],
              ),
            ),
          )
      ));
  }
}


