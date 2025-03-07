import 'package:flutter/material.dart';

class StudentDashbord extends StatelessWidget {
  const StudentDashbord({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 10, // Increased elevation for better shadow
              shadowColor: Colors.black.withOpacity(0.5), // Subtle shadow color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
              child: Container(
                width: isTablet ? 600 : 350, // Responsive width
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 68, 113, 237), // Blue
                      const Color.fromARGB(255, 246, 87, 140), // Purple
                      const Color.fromARGB(255, 216, 37, 240), // Pink
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5), // Shadow for depth
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Title
                    Text(
                      "Padhai Card",
                      style: TextStyle(
                        fontSize: isTablet ? 48 : 40, // Responsive font size
                        fontFamily: 'Paci',
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name and Icon
                    Row(
                      children: [
                        Icon(
                          Icons.cast_for_education_sharp,
                          color: Colors.white,
                          size: isTablet ? 50 : 40, // Responsive icon size
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Anant Singh',
                          style: TextStyle(
                            color: const Color.fromRGBO(
                              238,
                              255,
                              2,
                              1,
                            ), // Yellow color
                            fontFamily: 'Queen',
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isTablet ? 40 : 35, // Responsive font size
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Optional Subtitle
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'E-Learning Platform',
                          style: TextStyle(
                            fontSize:
                                isTablet ? 22 : 18, // Responsive font size
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(width: 25),
                        Text('YOA :- 2025',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize:isTablet?22:18),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // const SizedBox(height: 10),
          ),
        ),
      ),
    );
  }
}
