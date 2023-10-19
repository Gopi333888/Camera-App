import 'dart:io';

import 'package:camera/screen/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomeScrn extends StatefulWidget {
  const HomeScrn({super.key});

  @override
  State<HomeScrn> createState() => _HomeScrnState();
}

File? selectedImage;
late List<Map<String, dynamic>> imageList = [];
List<File> recentimage = [];

class _HomeScrnState extends State<HomeScrn> {
  @override
  void initState() {
    initializeSelectedImage();
    fetchImage();
    super.initState();
  }

  Future<void> initializeSelectedImage() async {
    File? image = await selectImageFromCamera(context);
    setState(() {
      selectedImage = image;
    });
    if (selectedImage != null) {
      addimageToDb(selectedImage!.path);
      recentimage.add(selectedImage!);
    }
    fetchImage();
  }

  Future<void> fetchImage() async {
    List<Map<String, dynamic>> listFromDB = await getimageFromdb();
    setState(() {
      imageList = listFromDB;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff176dab),
          title: Text(
            "Camera Application",
            style: GoogleFonts.poppins(),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: GoogleFonts.montserrat(
                fontSize: 17, fontWeight: FontWeight.w500),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Gallery'),
            ],
          ),
        ),
        body: TabBarView(children: [
          recentimage.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: recentimage.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          showSelectedImageDialog(context, recentimage[index]);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.file(recentimage[index]),
                        ),
                      );
                    },
                  ),
                )
              : const Center(child: Text('Take a photo')),
          Container(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
              ),
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                final imagemap = imageList[index];
                final imageFile = File(imagemap['imagesrc']);
                final id = imagemap['id'];
                return InkWell(
                  onTap: () {
                    showSelectedImageDialog(context, imageFile);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(imageFile),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 30,
                        child: CircleAvatar(
                            child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Delete Image"),
                                  content: const Text(
                                      "Are you sure you want to delete ?"),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancel")),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await deleteImageFromDB(id);
                                          fetchImage();
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                          // ignore: use_build_context_synchronously
                                          snackBarFunction(
                                              context,
                                              "Successfully Deleted..",
                                              Colors.green);
                                        },
                                        child: const Text("Ok"))
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete),
                        )),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await initializeSelectedImage();
          },
          tooltip: 'Take a photo',
          backgroundColor: const Color(0xff176dab),
          child: const Icon(Icons.camera_alt_outlined),
        ),
      ),
    );
  }
}

Future<File?> selectImageFromCamera(BuildContext context) async {
  File? image;
  try {
    final pickimage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickimage != null) {
      image = File(pickimage.path);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    showSnakBar(context, e.toString(), Colors.red);
  }
  return image;
}

void showSnakBar(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    backgroundColor: color,
  ));
}

void snackBarFunction(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    backgroundColor: color,
  ));
}

void showSelectedImageDialog(BuildContext context, File imageFile) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: Image.file(imageFile),
        ),
      );
    },
  );
}
