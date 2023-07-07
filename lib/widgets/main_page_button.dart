import 'package:flutter/material.dart';

class MainPageButton extends StatelessWidget {
  final String routeName;
  final void Function() toggleFunction;
  final String? buttonText;

  const MainPageButton(
      {super.key,
      required this.routeName,
      required this.toggleFunction,
      this.buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Future(() => toggleFunction());
        await Navigator.of(context).pushNamed(routeName);
        toggleFunction();
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 16, 16, 205),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          buttonText ?? "",
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 254),
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
