import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mon_application/services/contact_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact>? _contacts;
  ContactService contactService = ContactService();
  bool _permissionDenied = false;

  _ContactScreenState(){
    Permission.contacts.isGranted.then((value) {
      if(value){
        _fetchContact();
        setState(() => _permissionDenied = false);
      } else {
        setState(() => _permissionDenied = true);
      }
    });
    
  }

  _fetchContact() async {
    List<Contact>? tempContactList;
    tempContactList = await contactService.getContacts();
    setState(() {
        _contacts = tempContactList;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _body());

  Widget _body() {
    if (_permissionDenied) return const Center(child: Text('Permission denied'));
    if (_contacts == null) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder: (context, i) => ListTile(
          title: Text(_contacts![i].displayName),
          onTap: () async {
            print("Taped");
        }));
  }
}