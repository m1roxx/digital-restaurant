import 'package:flutter/material.dart';

class ProfilePageTransition extends PageRouteBuilder {
  final Widget page;
  final Offset begin;

  ProfilePageTransition({required this.page, required this.begin}) 
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );
            
            final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation);            
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
            
            final slideAnimation = Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(curvedAnimation);
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}