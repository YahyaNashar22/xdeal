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
      "three_sixty":
          "https://raw.githubusercontent.com/aframevr/aframe/master/examples/boilerplate/panorama/puydesancy.jpg",
      'price': '135000',
      "description":
          "This stunning villa offers breathtaking ocean views, a private beach, and luxurious amenities. Perfect for those seeking a serene coastal lifestyle.",
      'category': 'hotel',
      'coords': [33.896717365298535, 35.636843810038684],
      'bedrooms': 2,
      'bathrooms': 2,
      'space': 280,
      "extra_features": ["Ocean View", "Gourmet Kitchen"],
      'is_featured': false,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        '_id': '1',
        "full_name": "Yahya Nashar",
        'email': 'yahyanashar22@gmail.com',
        'phone': '+96176153425',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:15:00',
    },
    {
      '_id': '2',
      'name': 'listing 2',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      "three_sixty":
          "https://raw.githubusercontent.com/aframevr/aframe/master/examples/boilerplate/panorama/puydesancy.jpg",
      'price': '95000',
      "description":
          "This stunning villa offers breathtaking ocean views, a private beach, and luxurious amenities. Perfect for those seeking a serene coastal lifestyle.",
      'category': 'apartment',
      'coords': [33.8945123456789, 35.630123456789],
      'bedrooms': 3,
      'bathrooms': 2,
      'space': 150,
      "extra_features": ["Swimming Pool", "Gourmet Kitchen"],
      'is_featured': true,
      'is_sponsored': false,
      'on_sale': false,
      'owner_id': {
        '_id': '2',
        "full_name": "Yahya Nashar",
        'email': 'owner2@example.com',
        'phone': '+96170123456',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:15:00',
    },
    {
      '_id': '3',
      'name': 'listing 3',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      "three_sixty":
          "https://raw.githubusercontent.com/aframevr/aframe/master/examples/boilerplate/panorama/puydesancy.jpg",
      'price': '210000',
      "description":
          "This stunning villa offers breathtaking ocean views, a private beach, and luxurious amenities. Perfect for those seeking a serene coastal lifestyle.",
      'category': 'villa',
      'coords': [33.89123456789, 35.640987654321],
      'bedrooms': 4,
      'bathrooms': 3,
      'space': 420,
      "extra_features": ["Ocean View", "Private Beach"],
      'is_featured': false,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        '_id': '3',
        "full_name": "Yahya Nashar",
        'email': 'owner3@example.com',
        'phone': '+96171123456',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:15:00',
    },
    {
      '_id': '4',
      'name': 'listing 4',
      'images': [
        'https://images.unsplash.com/photo-1583329550487-0fa300a4cd1a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8aW50ZXJpb3J8ZW58MHx8MHx8fDA%3D',
        'https://images.unsplash.com/photo-1585128792020-803d29415281?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGludGVyaW9yfGVufDB8fDB8fHww',
      ],
      "three_sixty":
          "https://raw.githubusercontent.com/aframevr/aframe/master/examples/boilerplate/panorama/puydesancy.jpg",
      'price': '75000',
      "description":
          "This stunning villa offers breathtaking ocean views, a private beach, and luxurious amenities. Perfect for those seeking a serene coastal lifestyle.",
      'category': 'studio',
      'coords': [33.89987654321, 35.633456789012],
      'bedrooms': 1,
      'bathrooms': 1,
      'space': 70,
      "extra_features": [
        "Ocean View",
        "Private Beach",
        "Swimming Pool",
        "Gourmet Kitchen",
      ],
      'is_featured': true,
      'is_sponsored': false,
      'on_sale': false,
      'owner_id': {
        '_id': '4',
        "full_name": "Yahya Nashar",
        'email': 'owner4@example.com',
        'phone': '+96176111222',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:15:00',
    },
  ];

  static List<Map<String, dynamic>> vehiclesListings = [
    {
      '_id': '1',
      'name': '2025 Toyota Tundra Capstone CrewMax iForce Max Hybrid',
      'images': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8U1VWfGVufDB8fDB8fHww',
        'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U1VWfGVufDB8fDB8fHww',
      ],
      'price': '84074',
      'category': 'pickup',
      'brand': 'Toyota',
      'model': 'Tundra Capstone CrewMax',
      'version': 'iForce Max Hybrid',
      'condition': 'new',
      'kilometers': 0,
      'year': '2025',
      'fuel_type': 'hybrid',
      'transmission_type': 'automatic',
      'body_type': 'pickup',
      'power': 437, // HP
      'consumption': 11.8, // L/100km
      'air_conditioning': 'automatic',
      'color': 'white',
      'number_of_seats': 5,
      'number_of_doors': 4,
      "interior": "full leather",
      "payment_option": "installment",
      'description': 'Luxury full-size pickup with advanced features.',
      'coords': [33.896717365298535, 35.636843810038684],
      'extra_features': [
        'heated seats',
        'key less entry',
        'steering switches',
        'key less start',
        'power seats',
        'touch screen',
      ],
      'is_featured': true,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        '_id': '1',
        "full_name": "Yahya Nashar",
        'email': 'owner1@example.com',
        'phone': '+96176153425',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:15:00',
    },
    {
      '_id': '2',
      'name': '2025 Mazda CX-50 Hybrid',
      'images': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8U1VWfGVufDB8fDB8fHww',
        'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U1VWfGVufDB8fDB8fHww',
      ],
      'price': '42065',
      'category': 'SUV',
      'brand': 'Mazda',
      'model': 'CX-50',
      'version': 'Hybrid',
      'condition': 'new',
      'kilometers': 0,
      'year': '2025',
      'fuel_type': 'hybrid',
      'transmission_type': 'automatic',
      'body_type': 'SUV',
      'power': 219, // HP
      'consumption': 6.9, // L/100km
      'air_conditioning': 'automatic',
      'color': 'silver',
      'number_of_seats': 5,
      'number_of_doors': 2,
      "interior": "full leather",
      "payment_option": "cash",
      'description': 'Efficient hybrid SUV with advanced features.',
      'coords': [33.896717365298535, 35.636843810038684],
      'extra_features': [
        'power windows',
        'steering switches',
        'key less start',
        'power seats',
        'touch screen',
      ],
      'is_featured': true,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        '_id': '2',
        "full_name": "Yahya Nashar",
        'email': 'owner2@example.com',
        'phone': '+96176153426',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:20:00',
    },
    {
      '_id': '3',
      'name': '2025 Ford Escape Hybrid',
      'images': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8U1VWfGVufDB8fDB8fHww',
        'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U1VWfGVufDB8fDB8fHww',
      ],
      'price': '33970',
      'category': 'SUV',
      'brand': 'Ford',
      'model': 'Escape',
      'version': 'Hybrid',
      'condition': 'new',
      'kilometers': 0,
      'year': '2025',
      'fuel_type': 'hybrid',
      'transmission_type': 'automatic',
      'body_type': 'SUV',
      'power': 200, // HP
      'consumption': 6.7, // L/100km
      'air_conditioning': 'automatic',
      'color': 'blue',
      'number_of_seats': 5,
      'number_of_doors': 4,
      "interior": "full leather",
      "payment_option": "cash",
      'description': 'Compact hybrid SUV with modern features.',
      'coords': [33.896717365298535, 35.636843810038684],
      'extra_features': [
        'heated seats',
        'key less entry',
        'power mirrors',
        'power steering',
        'power windows',
      ],
      'is_featured': true,
      'is_sponsored': true,
      'on_sale': true,
      'owner_id': {
        '_id': '3',
        "full_name": "Yahya Nashar",
        'email': 'owner3@example.com',
        'phone': '+96176153427',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:25:00',
    },
    {
      '_id': '4',
      'name': '2025 Honda Civic Si',
      'images': [
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8U1VWfGVufDB8fDB8fHww',
        'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U1VWfGVufDB8fDB8fHww',
      ],
      'price': '23220',
      'category': 'sedan',
      'brand': 'Honda',
      'model': 'Civic Si',
      'version': 'Sport Compact',
      'condition': 'new',
      'kilometers': 0,
      'year': '2025',
      'fuel_type': 'gasoline',
      'transmission_type': 'manual',
      'body_type': 'sedan',
      'power': 158, // HP
      'consumption': 7.1, // L/100km
      'air_conditioning': 'manual',
      'color': 'red',
      'number_of_seats': 5,
      'number_of_doors': 2,
      "interior": "full leather",
      "payment_option": "installment",
      'description': 'Sporty compact sedan with manual transmission.',
      'coords': [33.896717365298535, 35.636843810038684],
      'extra_features': [
        'heated seats',
        'key less entry',
        'power mirrors',
        'power steering',
        'power windows',
        'steering switches',
        'key less start',
        'power seats',
        'touch screen',
      ],
      'is_featured': false,
      'is_sponsored': false,
      'on_sale': true,
      'owner_id': {
        '_id': '4',
        "full_name": "Yahya Nashar",
        'email': 'owner4@example.com',
        'phone': '+96176153428',
        "profile_picture":
            "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
      },
      'createdAt': '2025-09-16T11:30:00',
    },
  ];

  static Map<String, dynamic> owner = {
    '_id': '4',
    "full_name": "Yahya Nashar",
    'email': 'owner4@example.com',
    'phone': '+96176153428',
    "profile_picture":
        "https://images.unsplash.com/photo-1624355209556-98f79a93fb7a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHN0ZXdpZXxlbnwwfHwwfHx8MA%3D%3D",
    "number_of_listings": 25,
  };
}
