import 'dart:async';

import 'package:flutter/material.dart';

import 'posts_list_screen.dart';

class HomeScreen extends StatefulWidget {
	const HomeScreen({super.key});

	@override
	State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	bool _isLoading = false;

	Future<void> _startApp() async {
		if (_isLoading) return;

		setState(() {
			_isLoading = true;
		});

		await Future<void>.delayed(const Duration(seconds: 2));

		if (!mounted) return;

		await Navigator.of(context).pushReplacement(
			MaterialPageRoute<void>(
				builder: (_) => const PostsListScreen(),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
				width: double.infinity,
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [
							Color(0xFFF9EAEA),
							Color(0xFFFFFFFF),
						],
					),
				),
				child: SafeArea(
					child: Padding(
						padding: const EdgeInsets.all(24),
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								const Icon(
									Icons.article_rounded,
									size: 90,
									color: Color(0xFF800000),
								),
								const SizedBox(height: 20),
								const Text(
									'Offline Posts Manager',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 30,
										fontWeight: FontWeight.bold,
										color: Color(0xFF800000),
									),
								),
								const SizedBox(height: 12),
								Text(
									'Create, read, edit, and delete posts locally even without internet.',
									textAlign: TextAlign.center,
									style: TextStyle(
										fontSize: 15,
										color: Colors.grey[700],
										height: 1.4,
									),
								),
								const SizedBox(height: 36),
								SizedBox(
									width: double.infinity,
									child: ElevatedButton(
										onPressed: _isLoading ? null : _startApp,
										style: ElevatedButton.styleFrom(
											padding: const EdgeInsets.symmetric(vertical: 16),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(12),
											),
										),
										child: _isLoading
												? const Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															SizedBox(
																width: 20,
																height: 20,
																child: CircularProgressIndicator(
																	strokeWidth: 2,
																	color: Colors.white,
																),
															),
															SizedBox(width: 12),
															Text('Loading...'),
														],
													)
												: const Text(
														'Get Started',
														style: TextStyle(
															fontSize: 16,
															fontWeight: FontWeight.w600,
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
