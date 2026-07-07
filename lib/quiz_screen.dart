import 'package:flutter/material.dart';
import 'quiz_service.dart';
import 'dart:async';

class QuizScreen extends StatefulWidget {

  final String difficulty;
  final int category;

  const QuizScreen({
    super.key,
    required this.difficulty,
    required this.category,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();

}


class _QuizScreenState extends State<QuizScreen> {


  final QuizService _service = QuizService();


  List<dynamic> questions = [];

  int questionIndex = 0;

  int score = 0;

  bool loading = true;

  Timer? timer;

  int timeLeft = 15;

  List<String> options = [];

  bool showOptions = false;



  @override
  void initState() {

    super.initState();

    loadQuiz();

  }



  Future<void> loadQuiz() async {

    try {

      print("Loading ${widget.difficulty} quiz...");


      final data = await _service.fetchQuestions(

        difficulty: widget.difficulty,

        category: widget.category,

      );


      print("Questions Received: ${data.length}");



      setState(() {

        questions = data;

        loading = false;

      });



      generateOptions();


      setState(() {

        showOptions = true;

      });


      startTimer();



    } catch(e) {


      print("ERROR: $e");


      setState(() {

        loading = false;

        questions = [];

      });


    }

  }




  void checkAnswer(String selectedAnswer) {


    timer?.cancel();


    final correctAnswer =
    questions[questionIndex]['correct_answer'];



    if(selectedAnswer == correctAnswer){

      score++;

    }


    nextQuestion();


  }





  void generateOptions(){


    options = List<String>.from(

        questions[questionIndex]['incorrect_answers']

    );


    options.add(

        questions[questionIndex]['correct_answer']

    );


    options.shuffle();


  }






  void startTimer(){


    timeLeft = 15;


    timer?.cancel();


    timer = Timer.periodic(

      const Duration(seconds: 1),

          (timer){


        if(timeLeft > 0){


          setState((){

            timeLeft--;

          });


        }else{


          timer.cancel();

          nextQuestion();


        }


      },

    );


  }





  void nextQuestion(){



    if(questionIndex < questions.length - 1){



      setState((){


        questionIndex++;

        showOptions = false;


      });



      generateOptions();



      Future.delayed(

        const Duration(milliseconds: 200),

            (){

          setState(() {

            showOptions = true;

          });


        },

      );



      startTimer();



    }else{


      timer?.cancel();

      showResult();


    }


  }
  void resetQuiz(){


    setState((){


      questionIndex = 0;

      score = 0;

      loading = true;

      questions = [];

      showOptions = false;


    });


    loadQuiz();


  }





  void showResult() {


    showDialog(

      context: context,

      builder: (_) => AlertDialog(

        title: const Text("Quiz Finished 🎉"),

        content: Text(

          "Difficulty: ${widget.difficulty.toUpperCase()}\n\n"
              "Your Score: $score / ${questions.length}",

        ),


        actions: [


          TextButton(

            onPressed: () {

              Navigator.pop(context);

              resetQuiz();

            },

            child: const Text("Restart"),

          ),



          TextButton(

            onPressed: () {

              Navigator.pop(context);

              Navigator.pop(context);

            },

            child: const Text("Home"),

          ),


        ],

      ),

    );


  }






  @override
  Widget build(BuildContext context) {



    if (loading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }



    if (questions.isEmpty) {


      return const Scaffold(

        body: Center(

          child: Text(

            "No Questions Found",

            style: TextStyle(fontSize: 18),

          ),

        ),

      );


    }




    final currentQuestion = questions[questionIndex];



    return Scaffold(



      appBar: AppBar(

        title: Text(

          "Quiz App (${widget.difficulty.toUpperCase()})",

          style: const TextStyle(

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


          padding: const EdgeInsets.all(16),



          child: Column(


            crossAxisAlignment: CrossAxisAlignment.stretch,


            children: [



              Text(

                "Question ${questionIndex + 1} of ${questions.length}",


                style: const TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  color: Color(0xff2D3436),

                ),

              ),




              const SizedBox(height: 15),





              Center(

                child: Container(

                  padding: const EdgeInsets.all(15),


                  decoration: BoxDecoration(

                    color: const Color(0xff6C5CE7),

                    borderRadius: BorderRadius.circular(50),

                  ),



                  child: Text(

                    "⏰ $timeLeft",


                    style: const TextStyle(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight: FontWeight.bold,

                    ),

                  ),


                ),

              ),




              const SizedBox(height: 25),




              Container(

                padding: const EdgeInsets.all(20),


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




                child: AnimatedSwitcher(

                  duration: const Duration(milliseconds: 500),


                  transitionBuilder: (child, animation){


                    return FadeTransition(

                      opacity: animation,


                      child: ScaleTransition(

                        scale: animation,


                        child: child,

                      ),

                    );


                  },



                  child: Text(


                    currentQuestion['question'],


                    key: ValueKey(

                      currentQuestion['question'],

                    ),



                    textAlign: TextAlign.center,



                    style: const TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                      color: Color(0xff2D3436),

                    ),


                  ),

                ),

              ),





              const SizedBox(height: 25),






              ...options.asMap().entries.map((entry){


                final index = entry.key;

                final answer = entry.value;




                return AnimatedSlide(

                  duration: Duration(

                    milliseconds: 300 + (index * 100),

                  ),


                  offset: showOptions

                      ? Offset.zero

                      : const Offset(1,0),




                  child: AnimatedOpacity(

                    duration: Duration(

                      milliseconds: 300 + (index * 100),

                    ),



                    opacity: showOptions ? 1 : 0,




                    child: Padding(

                      padding: const EdgeInsets.only(bottom: 12),




                      child: ElevatedButton(



                        style: ElevatedButton.styleFrom(


                          backgroundColor:

                          const Color(0xff6C5CE7),


                          foregroundColor: Colors.white,



                          padding:

                          const EdgeInsets.symmetric(

                            vertical: 16,

                          ),




                          elevation: 5,



                          shape:

                          RoundedRectangleBorder(

                            borderRadius:

                            BorderRadius.circular(20),

                          ),



                        ),




                        onPressed: () => checkAnswer(answer),




                        child: Text(


                          answer,



                          textAlign: TextAlign.center,



                          style: const TextStyle(

                            fontSize: 16,

                          ),


                        ),


                      ),

                    ),

                  ),

                );


              }).toList(),



            ],


          ),

        ),

      ),

    );

  }

}