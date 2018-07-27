import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  String usernameValue;
  String passwordValue;
  bool _switchListValue = false;
  final GlobalKey<FormState> _authFormKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authmode = AuthMode.Signin;

  final Map<String, dynamic> _authFormData = {
    'email': null,
    'password': null,
    'acceptTerms': false,
    'updates': false
  };

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
      image: AssetImage('assets/background.jpg'),
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.purple),
      ),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Valid email is required';
        }
      },
      onSaved: (String value) {
        _authFormData['email'] = value;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      controller: _passwordTextController,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.purple),
      ),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                .hasMatch(value)) {
          return 'Password must contain atleast one letter ans one number';
        }
      },
      onSaved: (String value) {
        _authFormData['password'] = value;
      },
    );
  }

  Widget _buildConfirmPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.purple),
      ),
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Passwords doesnt match';
        }
      },
    );
  }

  Widget _buildSwitchList() {
    return SwitchListTile(
      title: Text('Accept terms'),
      value: _authFormData['acceptTerms'],
      onChanged: (value) {
        setState(() {
          _authFormData['acceptTerms'] = value;
        });
        print(_switchListValue);
      },
    );
  }

  Widget _buildCkeckBoxList() {
    return CheckboxListTile(
      title: Text('ether'),
      value: _authFormData['updates'],
      onChanged: (value) {
        setState(() {
          _authFormData['updates'] = value;
        });
      },
    );
  }

  void _submitForm(Function authMode) async {
    if (!_authFormKey.currentState.validate() ||
        !_authFormData['acceptTerms']) {
      return;
    }
    _authFormKey.currentState.save();

    final Map<String, dynamic> res = await authMode(
        _authFormData['email'], _authFormData['password'], _authmode);

    if (res['success']) {
      Navigator.pushReplacementNamed(context, '/products');
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error message'),
              content: Text(res['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Back'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          });
    }

    print('Username: $usernameValue, Password: $passwordValue');
  }

  @override
  Widget build(BuildContext context) {
    final double deveiceWidth = MediaQuery.of(context).size.width;
    final double targetWidth =
        deveiceWidth > 550.0 ? 500.0 : deveiceWidth * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: _buildBackgroundImage(),
        ),
        padding: EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: Form(
              key: _authFormKey,
              child: SingleChildScrollView(
                child: Container(
                  width: targetWidth,
                  child: Column(
                    children: [
                      _buildEmailTextField(),
                      SizedBox(
                        height: 10.0,
                      ),
                      _buildPasswordTextField(),
                      SizedBox(
                        height: 10.0,
                      ),

                      _authmode == AuthMode.Signup
                          ? _buildConfirmPasswordTextField()
                          : Container(),
                      _buildSwitchList(),
                      SizedBox(
                        height: 10.0,
                      ),
                      FlatButton(
                        child: Text(
                            'Swicth to ${_authmode == AuthMode.Signin ? 'SignUp' : 'Signin'}'),
                        onPressed: () {
                          setState(() {
                            _authmode = _authmode == AuthMode.Signin
                                ? AuthMode.Signup
                                : AuthMode.Signin;
                          });
                        },
                      ),
                      // _buildCkeckBoxList(),
                      SizedBox(height: 20.0),
                      ScopedModelDescendant<MainModel>(builder:
                          (BuildContext context, Widget child,
                              MainModel model) {
                        return model.isLoading == true
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                onPressed: () => _submitForm(model.authMode),
                                child: Text(
                                  _authmode == AuthMode.Signin
                                      ? 'Login'
                                      : 'Signup',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                              );
                      })
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
