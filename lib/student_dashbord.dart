import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isExpanded = false; // Toggle state for animation

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text('Welcome', style: TextStyle(color: Colors.blue)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded; // Toggle animation on tap
                    });
                  },
                  child: Card(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      width:
                          isTablet
                              ? (_isExpanded ? 650 : 600)
                              : (_isExpanded ? 370 : 350),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              _isExpanded
                                  ? [
                                    Colors.purple,
                                    Colors.blueAccent,
                                    Colors.teal,
                                  ]
                                  : [
                                    const Color.fromARGB(255, 68, 113, 237),
                                    const Color.fromARGB(255, 246, 87, 140),
                                    const Color.fromARGB(255, 216, 37, 240),
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Padhai Card",
                            style: TextStyle(
                              fontSize: isTablet ? 48 : 40,
                              fontFamily: _isExpanded ? 'Paci' : 'Poppins',
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

                          Row(
                            children: [
                              Icon(
                                Icons.cast_for_education_sharp,
                                color: Colors.white,
                                size: isTablet ? 50 : 40,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Anant Singh',
                                style: TextStyle(
                                  color: const Color.fromRGBO(238, 255, 2, 1),
                                  fontFamily: 'Queen',
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 40 : 35,
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

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Text(
                                'E-Learning Platform',
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 18,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 25),
                              Text(
                                'YOA :- 2025',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                  fontSize: isTablet ? 22 : 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'My Courses',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Card(
                  color: Color.fromARGB(211, 255, 238, 202),
                  shadowColor: Colors.grey,
                  child: Column(
                    children: [
                      Icon(Icons.science, color: Color.fromRGBO(0, 0, 0, 1)),
                    ],
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
