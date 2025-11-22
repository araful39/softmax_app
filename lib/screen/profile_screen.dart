import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: StreamBuilder(
        stream: provider.profileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile found"));
          }

          final profile = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profile.image ?? ""),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "${profile.firstName} ${profile.lastName}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  title: const Text("Email"),
                  subtitle: Text(profile.email ?? "N/A"),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Phone"),
                  subtitle: Text(profile.phone ?? "N/A"),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Age"),
                  subtitle: Text(profile.age.toString()),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Gender"),
                  subtitle: Text(profile.gender ?? ""),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
