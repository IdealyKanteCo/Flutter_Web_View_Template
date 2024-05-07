import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  ContactService(){
    FlutterContacts.requestPermission();
  }

  Future<List<Contact>?> getContacts() async {
    List<Contact>? contacts = await FlutterContacts.getContacts();
    return contacts;
  }
}