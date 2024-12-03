import 'package:flutter/material.dart';

class SignupProfilePreferencesPage extends StatefulWidget
{
  const SignupProfilePreferencesPage({super.key});

  @override
  SignupProfilePreferencesPageState createState() => SignupProfilePreferencesPageState();
}

//Class to locally adjust profile settings such as theme
class SignupProfilePreferencesPageState extends State<SignupProfilePreferencesPage>
{
  String? _selectedTheme; //Store the selected theme (dark or light)

  @override
  Widget build(BuildContext context)
  {

    //App bar definition
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup your preferences'),
        automaticallyImplyLeading: false, //Dont allow arrow back
      ),

      //Body definition
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //Text for title regarding theme for app
            const Text(
              "App Theme",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10), //Spacing for aesthetics

            //Definition for the actual radio buttons regarding theme
            Row(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'Light',
                      groupValue: _selectedTheme, //Null by default
                      onChanged: (value) {
                        setState(() {
                          _selectedTheme = value; //Update on click
                        });
                      },
                    ),
                    const Text('Light'),
                  ],
                ),

                const SizedBox(width: 20),

                Row(
                  children: [
                    Radio<String>(
                      value: 'Dark',
                      groupValue: _selectedTheme, //null value by default
                      onChanged: (value) {
                        setState(()
                        {
                          _selectedTheme = value; //Update on click
                        });
                      },
                    ),
                    const Text('Dark'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 70), //Spacing for aesthetics

            //Create the account button definition
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: ()
                    {
                      //Make sure the user filled the required fields
                      if(_selectedTheme != null)
                        {
                          ScaffoldMessenger.of(context).showSnackBar( //Output success in snackbar for login page
                            const SnackBar(
                              content: Text('Account Successfully Created!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context); //Start navigator pop chain, returning user to main menu
                        }
                      else //If fields are missing, put error in snackbar
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All required selections must be made!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                    },
                    child: const Text("Create My Account!"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}