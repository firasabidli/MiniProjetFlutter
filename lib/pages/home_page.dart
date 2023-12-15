import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';

String generateUniqueId() {
  return Random().nextInt(1000000).toString(); // Adjust as needed
}

class MenuItem {
  final String id;
  final String name;
  final String photo;
  final int quantity;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    required this.photo,
    required this.quantity,
    required this.price,
  });
  MenuItem copyWith({
    String? id,
    String? name,
    String? photo,
    int? quantity,
    double? price,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'quantity': quantity,
      'price': price,
    };
  }
}

class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({
    required this.title,
    required this.items,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController photoController = TextEditingController();

  Map<String, bool> isUpdatingMap = {};
  List<MenuSection> menuSections = [];
  late MenuItem newItem = MenuItem(
    id: generateUniqueId(),
    name: 'New Item',
    photo: 'https://example.com/default-photo.jpg',
    quantity: 0,
    price: 0.0,
  );

  @override
  void initState() {
    super.initState();
    fetchMenuData('http://localhost:3000/entrees', 'entrees');
    fetchMenuData('http://localhost:3000/order', 'order');
    fetchMenuData('http://localhost:3000/plats_principaux', 'plats_principaux');
    fetchMenuData(
        'http://localhost:3000/options_vegetariennes', 'options_vegetariennes');
    fetchMenuData('http://localhost:3000/desserts', 'desserts');
    fetchMenuData('http://localhost:3000/boissons', 'boissons');
    fetchMenuData(
        'http://localhost:3000/specialites_maison', 'specialites_maison');
  }
  Future<void> _showCreateFormDialog(String sectionTitle) async {
    String newItemId = generateUniqueId();
    MenuItem newItem = MenuItem(
      id: newItemId,
      name: '',
      photo: 'https://example.com/default-photo.jpg',
      quantity: 0,
      price: 0.0,
    );

    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController photoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Add Item to $sectionTitle'),
        content: Container(
        height: 300, // Set the desired height
        child: Column(
        children: [
              TextField(
                controller: nameController,
                onChanged: (value) {
                  setState(() {
                    newItem = newItem.copyWith(name: value);
                  });
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                onChanged: (value) {
                  setState(() {
                    newItem = newItem.copyWith(price: double.tryParse(value) ?? 0.0);
                  });
                },
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: quantityController,
                onChanged: (value) {
                  setState(() {
                    newItem = newItem.copyWith(quantity: int.tryParse(value) ?? 0);
                  });
                },
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: photoController,
                onChanged: (value) {
                  setState(() {
                    newItem = newItem.copyWith(photo: value);
                  });
                },
                decoration: InputDecoration(labelText: 'Photo URL'),
              ),
            ],
          ),
        ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel),
              label: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Call the createMenuItem method with the new item and section title
                createMenuItem(newItem, 'http://localhost:3000/$sectionTitle');
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.send),
              label: Text('Add'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }





  String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> createMenuItem(MenuItem newItem, String apiUrl) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newItem
            .toJson()), // Appeler toJson pour obtenir une représentation JSON
      );

      if (response.statusCode == 201) {
        print('Item created successfully');
        await Navigator.of(context).popAndPushNamed('homePage');
      } else {
        print('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating item: $e');
    }
  }

  Future<void> fetchMenuData(String apiUrl, String sectionTitle) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        dynamic decodedBody = json.decode(response.body);

        if (decodedBody is List<dynamic>) {
          setState(() {
            menuSections.add(MenuSection(
              title: sectionTitle,
              items: decodedBody.map((item) {
                var photo = item['photo'];
                if (photo is int) {
                  photo = photo.toString();
                }
                return MenuItem(
                  id: item['id']?.toString() ?? '0',
                  name: item['name'] ?? '',
                  photo: item['photo'] ?? '',
                  quantity: item['quantity'] ?? 0,
                  price: item['price']?.toDouble() ?? 0.0,
                );
              }).toList(),
            ));
          });
        }
      } else {
        print('Failed to fetch menu data from $apiUrl: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu data: $e');
    }
  }

  Future<void> updateMenuItem(MenuItem updatedItem, String apiUrl) async {
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedItem
            .toJson()), // Appeler toJson pour obtenir une représentation JSON
      );

      if (response.statusCode == 200) {
        print('Item updated successfully');
        await Navigator.of(context).popAndPushNamed('homePage');
      } else {
        print('Failed to update item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<void> deleteMenuItem(String apiUrl) async {
    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print('Item deleted successfully');
        await Navigator.of(context).popAndPushNamed('homePage');
      } else {
        print('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App'),
        backgroundColor: Colors.deepOrangeAccent,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: Drawer(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            UserAccountsDrawerHeader(
              accountName: Text(user.email!),
              accountEmail: null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.deepOrangeAccent,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,

                // Set the background color of the Drawer to red
              ),
            ),


            // ... Add more drawer items as needed
            Spacer(), // This will push the sign-out button to the bottom
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrangeAccent,

                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),

              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.exit_to_app, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 16),
            Text(
              'Welcome to Our Amazing Restaurant',
              style: TextStyle(fontSize: 24,  // Adjust the font size as needed
                fontWeight: FontWeight.bold,  // Use FontWeight.bold for a bold style
                color: Colors.deepOrange,
                ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                  itemCount: menuSections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Display the carousel slider at the top
                      return _buildCarouselSlider();
                    } else {
                      // Subtract 1 to adjust for the carousel slider
                      MenuSection section = menuSections[index - 1];


    return Column(
    children: [
    SizedBox(height: 16),
    _buildSectionTitle(section.title),
    ...section.items.map((item) =>
    _buildMenuItemCard(section, item)),
    ],
    );
    }
    },
    )

              ),

          ],
        ),
      ),


    );
  }

  // ...
  Widget _buildCarouselSlider() {
    return CarouselSlider(
      items: [
        // Add your image widgets here
        Image.network('https://www.heraldtribune.com/gcdn/authoring/2019/06/26/NSHT/ghows-LK-8c18d1ea-2228-1fe7-e053-0100007f4e92-7ed4c5c4.jpeg?width=660&height=440&fit=crop&format=pjpg&auto=webp'),
        Image.network('https://static.independent.co.uk/s3fs-public/thumbnails/image/2017/02/24/17/chef.jpg?quality=75&width=1200&auto=webp'),
        Image.network('https://www.shutterstock.com/image-photo/african-american-female-chef-having-600nw-2150289105.jpg'),
      ],
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.5, // Adjust the height as needed
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 1.0,
      ),
    );
  }
  Widget _buildMenuItemCard(MenuSection section, MenuItem item) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              item.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${item.quantity}'),
                Text('Price: \$${item.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Container(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              child: Image.network(
                item.photo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isUpdatingMap[item.id] ?? false)
            _buildUpdateForm(section, item)
          else
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isUpdatingMap[item.id] = true;
                      // Préremplissez les champs du formulaire avec les valeurs existantes
                      nameController.text = item.name;
                      priceController.text = item.price.toString();
                      quantityController.text = item.quantity.toString();
                      photoController.text = item.photo;
                    });
                  },
                  icon: Icon(Icons.edit),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber, // Use the warning color for "Update"
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    deleteMenuItem(
                        'http://localhost:3000/${section.title}/${item.id}');
                  },
                  icon: Icon(Icons.delete),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Use the danger color for "Delete"
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

// ...



  Widget _buildUpdateForm(MenuSection section, MenuItem item) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: priceController,
          decoration: InputDecoration(labelText: 'Price'),
        ),
        TextField(
          controller: quantityController,
          decoration: InputDecoration(labelText: 'Quantity'),
        ),
        TextField(
          controller: photoController, // Add this controller for the photo
          decoration: InputDecoration(labelText: 'Photo URL'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                String newName = nameController.text;
                double newPrice = double.parse(priceController.text);
                int newQuantity = int.parse(quantityController.text);
                String newPhoto = photoController.text;

                // Create a new MenuItem with the updated values
                MenuItem updatedItem = MenuItem(
                  id: item.id,
                  name: newName,
                  photo: newPhoto,
                  quantity: newQuantity,
                  price: newPrice,
                );

                // Call the updateMenuItem method with the updated item
                await updateMenuItem(updatedItem,
                    'http://localhost:3000/${section.title}/${item.id}');

                setState(() {
                  isUpdatingMap[item.id] = false;
                });
              },
              icon: Icon(Icons.save),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isUpdatingMap[item.id] = false;
                });
              },
              icon: Icon(Icons.cancel),
              label: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildSectionTitle(String title) {
    String sectionTitle;
    Color titleColor;
    Color titleBackgroundColor;

    switch (title) {
      case 'entrees':
        sectionTitle = 'Start Your Meal Right';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.blue;
        break;
      case 'order':
        sectionTitle = 'Your Orders So Far';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.green;
        break;
      case 'plats_principaux':
        sectionTitle = 'Main Course Delights';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.orange;
        break;
      case 'options_vegetariennes':
        sectionTitle = 'Vegetarian Choices';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.green;
        break;
      case 'desserts':
        sectionTitle = 'Sweet Indulgences';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.pink;
        break;
      case 'boissons':
        sectionTitle = 'Refreshing Beverages';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.teal;
        break;
      case 'specialites_maison':
        sectionTitle = 'House Specialties';
        titleColor = Colors.white;
        titleBackgroundColor = Colors.deepPurple;
        break;
      default:
        sectionTitle = title;
        titleColor = Colors.black; // Default color
        titleBackgroundColor = Colors.grey; // Default background color
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          color: titleBackgroundColor,
          child: Center(
            child: Text(
              sectionTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 13),
        Row(
        mainAxisAlignment: MainAxisAlignment.start, // Aligner le bouton à gauche
    children: [
    Container(
    margin: EdgeInsets.only(left: 10),
    child: ElevatedButton.icon(
          onPressed: () {
            // Call the _showCreateFormDialog method with the appropriate section title
            _showCreateFormDialog(title);
          },
          icon: Icon(Icons.add), // Add the icon for the "Add" button
          label: Text('Add $title'),
        ),
    ),
      SizedBox(height:18),
    ],
    ),
      ],
    );
  }
}
