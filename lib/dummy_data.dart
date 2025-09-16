class DummyData {
  static List<String> propertyCategories = [
    "Vacation Rentals",
    "Apartment",
    "Studio",
    "Chalet",
    "Cabins",
    "Mansions",
  ];

  static List<String> vehicleCategories = [
    "Cars",
    "Trucks",
    "Motorcycles",
    "Boats",
  ];

  static List<Map<String, dynamic>> ads = [
    {
      'title': 'ad1',
      'image':
          'https://images.unsplash.com/photo-1604759695540-3012f9682c28?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8YWR8ZW58MHx8MHx8fDA%3D',
    },
    {
      'title': 'ad2',
      'image':
          'https://images.unsplash.com/photo-1535446937720-e4cad0145efe?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGFkfGVufDB8fDB8fHww',
    },
    {
      'title': 'ad3',
      'image':
          'https://images.unsplash.com/photo-1529218402470-5dec8fea0761?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGFkfGVufDB8fDB8fHww',
    },
  ];

  static List<Map<String, dynamic>> propertiesListings = [
    {
      '_id': '1',
      'name': 'listing 1',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      'price': '135000',
      'category': 'hotel',
      'coords': [33.896717365298535, 35.636843810038684],
      'bedrooms': 2,
      'bathrooms': 2,
      'space': 280,
      'is_featured': false,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        'id': '1',
        'email': 'yahyanashar22@gmail.com',
        'phone': '+96176153425',
      },
      'createdAt': '20250916T1115',
    },
    {
      '_id': '2',
      'name': 'listing 2',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      'price': '95000',
      'category': 'apartment',
      'coords': [33.8945123456789, 35.630123456789],
      'bedrooms': 3,
      'bathrooms': 2,
      'space': 150,
      'is_featured': true,
      'is_sponsored': false,
      'on_sale': false,
      'owner_id': {
        'id': '2',
        'email': 'owner2@example.com',
        'phone': '+96170123456',
      },
      'createdAt': '20250910T0930',
    },
    {
      '_id': '3',
      'name': 'listing 3',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      'price': '210000',
      'category': 'villa',
      'coords': [33.89123456789, 35.640987654321],
      'bedrooms': 4,
      'bathrooms': 3,
      'space': 420,
      'is_featured': false,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        'id': '3',
        'email': 'owner3@example.com',
        'phone': '+96171123456',
      },
      'createdAt': '20250912T1400',
    },
    {
      '_id': '4',
      'name': 'listing 4',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      'price': '75000',
      'category': 'studio',
      'coords': [33.89987654321, 35.633456789012],
      'bedrooms': 1,
      'bathrooms': 1,
      'space': 70,
      'is_featured': true,
      'is_sponsored': false,
      'on_sale': false,
      'owner_id': {
        'id': '4',
        'email': 'owner4@example.com',
        'phone': '+96176111222',
      },
      'createdAt': '20250915T0830',
    },
  ];
}
