import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {

  final int score;

  final VoidCallback changeTheme;
  final bool isDarkMode;


  const ResultScreen({
    super.key,
    required this.score,
    required this.changeTheme,
    required this.isDarkMode,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Result",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        backgroundColor: const Color(0xff6C5CE7),

      ),


      body: Container(

        width: double.infinity,


        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xffF8F9FF),

              Color(0xffE8EAF6),

            ],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

        ),



        child: Center(

          child: Padding(

            padding: const EdgeInsets.all(20),


            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,


              children: [


                const Text(

                  "Quiz Completed 🎉",

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight: FontWeight.bold,

                    color: Color(0xff2D3436),

                  ),

                ),



                const SizedBox(height: 30),



                Container(

                  padding: const EdgeInsets.all(30),


                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(30),


                    boxShadow: const [

                      BoxShadow(

                        color: Colors.black12,

                        blurRadius: 10,

                        offset: Offset(0,5),

                      ),

                    ],

                  ),



                  child: Column(

                    children: [


                      const Text(

                        "Your Score",

                        style: TextStyle(

                          fontSize: 22,

                          fontWeight: FontWeight.bold,

                        ),

                      ),



                      const SizedBox(height: 15),



                      Text(

                        "$score",

                        style: const TextStyle(

                          fontSize: 50,

                          fontWeight: FontWeight.bold,

                          color: Color(0xff6C5CE7),

                        ),

                      ),


                    ],

                  ),

                ),



                const SizedBox(height: 40),




                SizedBox(

                  width: double.infinity,


                  height: 55,


                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: const Color(0xff6C5CE7),

                      foregroundColor: Colors.white,


                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25),

                      ),

                    ),


                    onPressed: () {


                      Navigator.pushAndRemoveUntil(

                        context,


                        MaterialPageRoute(

                          builder: (context) => HomeScreen(

                            changeTheme: changeTheme,

                            isDarkMode: isDarkMode,

                          ),

                        ),


                            (route) => false,

                      );


                    },


                    child: const Text(

                      "Restart Quiz",

                      style: TextStyle(

                        fontSize: 18,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                ),


              ],


            ),

          ),

        ),

      ),

    );

  }

}