import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = FirebaseStorage.instance.ref();
  final db = FirebaseFirestore.instance;
  final ImagePicker picker = ImagePicker();
  List<String> urls = [];
  List<XFile> images = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Upload"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.pink,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 26,
          ),
          Center(
            child: OutlinedButton(
              onPressed: pickImages,
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                width: 1,
                color: Colors.purple,
              )),
              child: const Text("Choose Images",
                  style: TextStyle(color: Colors.purple)),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                images.length,
                (index) => SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.file(
                    File(images[index].path),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 32,
          ),
          Visibility(
            visible: images.isNotEmpty,
            child: OutlinedButton(
              onPressed: () {
                images.clear();
                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                width: 1,
                color: Colors.pink,
              )),
              child: const Text("Clears Images",
                  style: TextStyle(color: Colors.pink)),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Visibility(
            visible: images.isNotEmpty,
            child: OutlinedButton(
              onPressed: uploadImagesToStorage,
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                width: 1,
                color: Colors.green,
              )),
              child: isLoading
                  ? const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.green,
                      ),
                    )
                  : const Text("Upload Images",
                      style: TextStyle(color: Colors.green)),
            ),
          ),
        ],
      ),
    );
  }

  void pickImages() async {
    try {
      images = await picker.pickMultiImage();
      setState(() {});
    } catch (e) {
      log(e.toString(), name: "PICK IMAGE ERROR");
    }
  }

  void uploadImagesToStorage() async {
    try {
      isLoading = true;
      setState(() {});
      final imageRef = storage.child("images");
      for (var image in images) {
        await imageRef.child(image.name).putFile(File(image.path));
        String imageUrl = await imageRef.child(image.name).getDownloadURL();
        urls.add(imageUrl);
        setState(() {});
      }

      await uploadImagesToStore();
    } catch (e) {
      log(e.toString(), name: "UPLOAD IMAGES TO STORAGE ERROR");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  uploadImagesToStore() async {
    try {
      final images = <String, dynamic>{
        "images": urls,
      };
      // Add a new document with a generated ID
      db.collection("images").add(images).then((DocumentReference doc) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Images uploaded successfully ${doc.id}😍🔥"),
          ),
        );
        urls.clear();
        images.clear();
      });
    } catch (e) {
      log(e.toString(), name: "UPLOAD IMAGES TO STORE ERROR");
    }
  }
}
