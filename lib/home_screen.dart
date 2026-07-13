
import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'package:quiz_app/document_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback changeTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.changeTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController controller;

  late Animation<Offset> slideAnimation;

  late Animation<double> fadeAnimation;



  @override
  void initState() {

    super.initState();


    controller = AnimationController(

      duration: const Duration(milliseconds: 900),

      vsync: this,

    );


    slideAnimation = Tween<Offset>(

      begin: const Offset(0, 0.5),

      end: Offset.zero,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.easeOut,

      ),

    );


    fadeAnimation = Tween<double>(

      begin: 0,

      end: 1,

    ).animate(controller);



    controller.forward();

  }



  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(


        appBar: AppBar(

          title: const Text(
            "Quiz App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),


          centerTitle: true,


          backgroundColor: const Color(0xff6C63FF),


          actions: [

            IconButton(

              onPressed: widget.changeTheme,


              icon: Icon(

                widget.isDarkMode

                    ? Icons.light_mode

                    : Icons.dark_mode,

              ),

            ),

          ],

        ),



        body: Container(

            width: double.infinity,


            decoration: BoxDecoration(

              gradient: LinearGradient(

                colors: widget.isDarkMode

                    ? [

                  const Color(0xff141E30),

                  const Color(0xff243B55),

                ]

                    : [

                  const Color(0xffE8EAF6),

                  const Color(0xffFFFFFF),

                ],


                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

              ),

            ),



            child: Padding(

                padding: const EdgeInsets.all(20),


                child: Column(

                    mainAxisAlignment: MainAxisAlignment.center,


                    children: [
                      const Icon(

                        Icons.quiz,

                        size: 90,

                        color: Color(0xff6C63FF),

                      ),



                      const SizedBox(height: 20),



                      Text(

                        "Quiz App",

                        style: TextStyle(

                          fontSize: 38,

                          fontWeight: FontWeight.bold,

                          color: widget.isDarkMode

                              ? Colors.white

                              : const Color(0xff2C2C54),

                        ),

                      ),



                      const SizedBox(height: 10),



                      Text(

                        "Test Your Knowledge 🚀",

                        style: TextStyle(

                          fontSize: 18,

                          color: widget.isDarkMode

                              ? Colors.white70

                              : Colors.grey.shade700,

                        ),

                      ),



                      const SizedBox(height: 45),



                      FadeTransition(

                        opacity: fadeAnimation,

                        child: SlideTransition(

                          position: slideAnimation,

                          child: difficultyButton(

                            context,

                            "🟢 Easy",

                            const Color(0xff20BF6B),

                            "easy",

                          ),

                        ),

                      ),



                      const SizedBox(height: 18),



                      FadeTransition(

                        opacity: fadeAnimation,

                        child: SlideTransition(

                          position: slideAnimation,

                          child: difficultyButton(

                            context,

                            "🟡 Medium",

                            const Color(0xffF7B731),

                            "medium",

                          ),

                        ),

                      ),
                      const SizedBox(height: 24),

                      FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DocumentUploadScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                              ),
                              label: const Text(
                                "AI Document Quiz",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff00B894),
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),



                      const SizedBox(height: 18),



                      FadeTransition(

                        opacity: fadeAnimation,

                        child: SlideTransition(

                          position: slideAnimation,

                          child: difficultyButton(

                            context,

                            "🔴 Hard",

                            const Color(0xffEB3B5A),

                            "hard",

                          ),

                        ),

                      ),


                    ],

                ),

            ),

        ),

    );

  }



  Widget difficultyButton(

      BuildContext context,

      String text,

      Color color,

      String difficulty,

      ) {


    return SizedBox(

      width: double.infinity,

      height: 55,


      child: ElevatedButton(


        style: ElevatedButton.styleFrom(


          backgroundColor: color,

          foregroundColor: Colors.white,

          elevation: 8,


          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(25),

          ),

        ),



        onPressed: () {


          Navigator.push(


            context,


            MaterialPageRoute(


              builder: (context) => CategoryScreen(

                difficulty: difficulty,

              ),


            ),


          );


        },



        child: Text(


          text,


          style: const TextStyle(


            fontSize: 20,

            fontWeight: FontWeight.bold,

          ),


        ),


      ),

    );

  }


}