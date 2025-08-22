import 'package:flutter/material.dart';
import 'package:social_media_app/features/home/presentation/components/my_drawer.dart';

import '../../../post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UploadPostPage())),
              icon: Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
    );
  }
}
