import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Image> uploadImage(File imageFile, Map data) async {
  var url = Uri.parse("http://127.0.0.1:8000/upload-image/");

  var request = http.MultipartRequest('POST', url);

  // Add the image file
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  for (var element in data.entries) {
    request.fields[element.key] = element.value;
  }

  // Send the request
  var response = await request.send();
  if (response.statusCode == 200) {
    var responseBody = await http.Response.fromStream(response);
    Uint8List imageBytes = responseBody.bodyBytes;
    String dir = "assets/images/output.jpg";
    File file = File(dir);
    await file.writeAsBytes(imageBytes);
    return Image.memory(imageBytes);
  } else {
    print("Failed to upload image: ${response.reasonPhrase}");
    return Image.asset('name');
  }
}

Future<List<String>> fetchSimilar(File imageFile, String searchPath) async {
  var url = Uri.parse("http://127.0.0.1:8000/get_similar/");

  var request = http.MultipartRequest('POST', url);

  // Add the image file
  request.files
      .add(await http.MultipartFile.fromPath('image', imageFile.path));

  request.fields['template_path'] = imageFile.path;
  request.fields['folder_path'] = searchPath;

  // Send the request
  var response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await http.Response.fromStream(response);
    List<String> similarImage =
        List<String>.from(json.decode(responseBody.body));
    print(similarImage);
    return similarImage;
  } else {
    print("Failed: ${response.reasonPhrase}");
    return [];
  }
}
