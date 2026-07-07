import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class CategoryScreen extends StatelessWidget {

  final String difficulty;

  const CategoryScreen({
    super.key,
    required this.difficulty,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Select Category",
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


        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [


              Text(

                "Difficulty: ${difficulty.toUpperCase()}",

                textAlign: TextAlign.center,

                style: const TextStyle(

                  fontSize: 22,

                  fontWeight: FontWeight.bold,

                  color: Color(0xff2D3436),

                ),

              ),



              const SizedBox(height: 30),



              const Text(

                "Choose Category 🎯",

                textAlign: TextAlign.center,

                style: TextStyle(

                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                  color: Color(0xff6C5CE7),

                ),

              ),



              const SizedBox(height: 40),



              Container(

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(25),

                  boxShadow: const [

                    BoxShadow(

                      color: Colors.black12,

                      blurRadius: 10,

                      offset: Offset(0,5),

                    ),

                  ],

                ),


                child: SizedBox(

                  height: 70,


                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(

                      backgroundColor: const Color(0xff6C5CE7),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(25),

                      ),

                    ),


                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (context) => QuizScreen(

                            difficulty: difficulty,

                            category: 18,

                          ),

                        ),

                      );

                    },


                    child: const Text(

                      "💻 Computers",

                      style: TextStyle(

                        fontSize: 20,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ),

                ),

              ),


            ],

          ),

        ),

      ),

    );

  }

}