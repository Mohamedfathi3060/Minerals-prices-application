import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../services/users.dart';

class UsersPage extends StatelessWidget {
  final service = UserService();
  UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: service.getUsers(), // Fetch users from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Show an error message if something goes wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no users are found
            return const Center(child: Text('No users found.'));
          }

          // Display the list of users
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.username?[0].toUpperCase() ?? '?'),
                ),
                title: Text(user.username ?? 'No Name'),
                subtitle: Text(user.email ?? 'No Email'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // await userService.deleteUser(user); // Delete user
                    Get.snackbar("Deleted", "${user.username} deleted!",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        colorText: Colors.red);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
