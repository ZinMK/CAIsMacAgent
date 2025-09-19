import 'package:supabase_flutter/supabase_flutter.dart';

class Supabasefunctions {
  Future<void> sendMessage(Map<String, dynamic> messageData) async {
    /* EXAMPLE MESSGAE DATA BLOCK
  
    final messageData = {
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
        'from': "Zin",
        'company': _companyController.text,
        'email': _emailController.text,
        'name': _nameController.text,
      };
*/
    await Supabase.instance.client.from('Chats').insert(messageData);
  }
}
