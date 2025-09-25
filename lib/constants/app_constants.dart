class AppConstants {
  // App Information
  static const String appName = 'SmartFarming';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1.0.1'; //suraj added for aboutscreen

  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleVerifier = 'verifier';
  static const String roleAdmin = 'admin';

  // Database
  static const String databaseName = 'smart_farmer.db';
  static const int databaseVersion = 3;

  // SharedPreferences Keys
  static const String keyLanguage = 'language';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Crop Lifespan in Days (for AI insights)
  static const Map<String, int> cropLifespan = {
    'Wheat': 120,
    'Rice': 150,
    'Maize': 100,
    'Cotton': 180,
    'Sugarcane': 365,
    'Pulses': 90,
    'Oilseeds': 120,
    'Vegetables': 60,
    'Fruits': 730,
    'Other': 120,
  };

  // Address models
  static const String stateMaharashtra = 'Maharashtra';
static const Map<String, List<String>> maharashtraDistricts = {
    'Ahmednagar': [
      'Ahmednagar',
      'Shrirampur',
      'Rahata',
      'Rahuri',
      'Sangamner',
      'Kopargaon',
      'Akole',
      'Nevasa',
      'Shevgaon',
      'Pathardi',
      'Parner',
      'Jamkhed',
      'Karjat',
    ],
    'Akola': ['Akola', 'Balapur', 'Patur', 'Telhara', 'Akot', 'Murtijapur'],
    'Amravati': [
      'Amravati',
      'Chandur Railway',
      'Chikhaldara',
      'Daryapur',
      'Dhamangaon Railway',
      'Morshi',
      'Nandgaon-Khandeshwar',
      'Anjangaon Surji',
      'Achalpur',
    ],
    'Aurangabad': [
      'Aurangabad',
      'Gangapur',
      'Vaijapur',
      'Sillod',
      'Kannad',
      'Paithan',
      'Khuldabad',
      'Phulambri',
    ],
    'Beed': [
      'Beed',
      'Ashti',
      'Ambejogai',
      'Patoda',
      'Kaij',
      'Georai',
      'Majalgaon',
      'Parli',
      'Shirur (Beed)',
    ],
    'Bhandara': ['Bhandara', 'Tumsar', 'Sakoli', 'Lakhani', 'Mohadi', 'Pauni'],
    'Buldhana': [
      'Buldhana',
      'Chikhli',
      'Mehkar',
      'Jalgaon Jamod',
      'Sangrampur',
      'Malkapur',
      'Deulgaon Raja',
      'Motala',
      'Nandura',
      'Shegaon',
    ],
    'Chandrapur': [
      'Chandrapur',
      'Warora',
      'Bhadravati',
      'Chimur',
      'Nagbhid',
      'Mul',
      'Saoli',
      'Rajura',
      'Pombhurna',
      'Ballarpur',
      'Gondpipri',
      'Korpana',
    ],
    'Dhule': ['Dhule', 'Shirpur', 'Sakri', 'Sindkheda'],
    'Gadchiroli': [
      'Gadchiroli',
      'Aheri',
      'Chamorshi',
      'Etapalli',
      'Armori',
      'Desaiganj (Wadsa)',
      'Korchi',
      'Kurkheda',
      'Mulchera',
    ],
    'Gondia': [
      'Gondia',
      'Tirora',
      'Goregaon',
      'Amgaon',
      'Arjuni Morgaon',
      'Deori',
      'Sadak Arjuni',
      'Salekasa',
    ],
    'Hingoli': ['Hingoli', 'Kalamnuri', 'Basmath', 'Sengaon'],
    'Jalgaon': [
      'Jalgaon',
      'Bhusawal',
      'Jamner',
      'Chalisgaon',
      'Erandol',
      'Yawal',
      'Amalner',
      'Pachora',
      'Parola',
      'Dharangaon',
    ],
    'Jalna': [
      'Jalna',
      'Bhokardan',
      'Jaffrabad',
      'Ambad',
      'Badnapur',
      'Mantha',
      'Partur',
      'Ghansawangi',
    ],
    'Kolhapur': [
      'Kolhapur',
      'Karveer',
      'Gaganbawada',
      'Radhanagari',
      'Ajra',
      'Bhudargad',
      'Chandgad',
      'Gadhinglaj',
      'Hatkanangale',
      'Kagal',
      'Panhala',
      'Shirol',
    ],
    'Latur': [
      'Latur',
      'Ahmadpur',
      'Udgir',
      'Nilanga',
      'Ausa',
      'Chakur',
      'Deoni',
      'Renapur',
      'Shirur Anantpal',
    ],
    'Mumbai City': ['Mumbai City'],
    'Mumbai Suburban': ['Mumbai Suburban'],
    'Nagpur': [
      'Nagpur',
      'Katol',
      'Narkhed',
      'Kalmeshwar',
      'Hingna',
      'Umred',
      'Parseoni',
      'Ramtek',
      'Bhiwapur',
      'Kuhi',
      'Mauda',
    ],
    'Nanded': [
      'Nanded',
      'Kinwat',
      'Hadgaon',
      'Bhokar',
      'Loha',
      'Naigaon',
      'Mukhed',
      'Deglur',
      'Kandhar',
      'Himayatnagar',
    ],
    'Nandurbar': [
      'Nandurbar',
      'Shahada',
      'Taloda',
      'Navapur',
      'Akkalkuwa',
      'Akrani (Dhadgaon)',
    ],
    'Nashik': [
      'Nashik',
      'Malegaon',
      'Sinnar',
      'Igatpuri',
      'Kalwan',
      'Dindori',
      'Chandwad',
      'Deola',
      'Niphad',
      'Peth',
      'Trimbakeshwar',
      'Baglan',
      'Yevla',
    ],
    'Osmanabad': [
      'Osmanabad',
      'Tuljapur',
      'Paranda',
      'Bhum',
      'Kalamb',
      'Lohara',
      'Umarga',
      'Vashi',
    ],
    'Parbhani': [
      'Parbhani',
      'Gangakhed',
      'Pathri',
      'Sonpeth',
      'Manwat',
      'Jintur',
      'Purna',
      'Palam',
      'Sailu',
    ],
    'Pune': [
      'Pune City',
      'Haveli',
      'Mulshi',
      'Bhor',
      'Baramati',
      'Indapur',
      'Junnar',
      'Daund',
      'Ambegaon',
      'Shirur',
      'Velhe',
      'Purandar',
      'Mawal',
      'Khed',
    ],
    'Raigad': [
      'Alibag',
      'Pen',
      'Mahad',
      'Murud',
      'Roha',
      'Shrivardhan',
      'Tala',
      'Uran',
      'Karjat',
      'Khalapur',
      'Mangaon',
      'Poladpur',
      'Sudhagad Pali',
    ],
    'Ratnagiri': [
      'Ratnagiri',
      'Mandangad',
      'Dapoli',
      'Khed',
      'Guhagar',
      'Chiplun',
      'Sangameshwar',
      'Lanja',
      'Rajapur',
    ],
    'Sangli': [
      'Sangli',
      'Miraj',
      'Tasgaon',
      'Kavathemahankal',
      'Jath',
      'Khanapur',
      'Palus',
      'Atpadi',
      'Walwa',
      'Shirala',
    ],
    'Satara': [
      'Satara',
      'Karad',
      'Wai',
      'Patan',
      'Mahabaleshwar',
      'Phaltan',
      'Khatav',
      'Koregaon',
      'Jaoli',
      'Man',
    ],
    'Sindhudurg': [
      'Sindhudurg',
      'Kudal',
      'Sawantwadi',
      'Dodamarg',
      'Vengurla',
      'Malvan',
      'Devgad',
      'Kankavli',
    ],
    'Solapur': [
      'Solapur North',
      'Solapur South',
      'Barshi',
      'Madha',
      'Karmala',
      'Mohol',
      'Pandharpur',
      'Sangole',
      'Akkalkot',
      'Malshiras',
    ],
    'Thane': [
      'Thane',
      'Kalyan',
      'Bhiwandi',
      'Murbad',
      'Ulhasnagar',
      'Ambarnath',
      'Shahapur',
    ],
    'Wardha': ['Wardha', 'Hinganghat', 'Deoli', 'Arvi', 'Seloo', 'Samudrapur'],
    'Washim': [
      'Washim',
      'Mangrulpir',
      'Karanja',
      'Manora',
      'Malegaon (Washim)',
      'Risod',
    ],
    'Yavatmal': [
      'Yavatmal',
      'Pusad',
      'Umarkhed',
      'Digras',
      'Arni',
      'Darwha',
      'Kelapur',
      'Ghatanji',
      'Ner',
      'Mahagaon',
      'Ralegaon',
      'Babulgaon',
    ],
  };

  static const List<String> maharashtraCrops = [
    // Cereals
    "Rice",
    "Wheat",
    "Jowar (Sorghum)",
    "Bajra (Pearl Millet)",
    "Maize",
    "Ragi (Finger Millet)",
    "Varai (Barnyard Millet)",
    "Kangni (Foxtail Millet)",

    // Pulses
    "Tur (Pigeon Pea)",
    "Moong (Green Gram)",
    "Udid (Black Gram)",
    "Chana (Chickpea)",
    "Matki (Moth Bean)",
    "Masoor (Lentil)",
    "Wal (Horse Gram)",
    "Kulith (Hyacinth Bean)",

    // Oilseeds
    "Soybean",
    "Groundnut",
    "Sunflower",
    "Safflower",
    "Sesame",
    "Castor",
    "Linseed",
    "Niger Seed",

    // Cash Crops
    "Cotton",
    "Sugarcane",
    "Tobacco",

    // Fruits
    "Mango",
    "Banana",
    "Orange",
    "Grapes",
    "Pomegranate",
    "Chikoo  (Sapota)",
    "Custard Apple",
    "Guava",
    "Papaya",
    "Jamun",
    "Ber (Indian Plum)",
    "Amla (Indian Gooseberry)",
    "Fig",
    "Karonda",
    "Wood Apple",
    "Tamarind",

    // Vegetables
    "Tomato",
    "Onion",
    "Brinjal (Eggplant)",
    "Ladyfinger (Okra)",
    "Chili",
    "Cabbage",
    "Cauliflower",
    "Potato",
    "Sweet Potato",
    "Carrot",
    "Radish",
    "Cucumber",
    "Bitter Gourd",
    "Bottle Gourd",
    "Ridge Gourd",
    "Sponge Gourd",
    "Spinach",
    "Fenugreek",
    "Drumstick",
    "Cluster Beans",
    "French Beans",
    "Peas",
    "Pumpkin",
    "Ash Gourd",
    "Snake Gourd",
    "Pointed Gourd",
    "Yam",
    "Colocasia",

    // Spices
    "Turmeric",
    "Coriander",
    "Cumin",
    "Fennel",
    "Garlic",
    "Ginger",
    "Black Pepper",
    "Cardamom",
    "Cloves",
    "Nutmeg",

    // Flowers (expanded)
    "Marigold",
    "Jasmine",
    "Rose",
    "Chrysanthemum",
    "Hibiscus",
    "Crossandra",
    "Tuberose",
    "Gladiolus",
    "Gerbera",
    "Orchid",

    // Medicinal Plants (expanded)
    "Aloe Vera",
    "Tulsi (Holy Basil)",
    "Ashwagandha",
    "Shatavari",
    "Stevia",
    "Lemongrass",
    "Sadabahar (Vinca)",
    "Henna",
    "Neem",
    "Brahmi",
    "Kalmegh",
    "Giloy",
    "Mint",
    "Basil",

    // Others
    "Cashew",
    "Coconut",
    "Betel Vine",
    "Rubber",
    "Coffee",
    "Tea",
    "Areca Nut",
    "Bamboo",
    "Sisal",

    // Fodder Crops
    "Lucerne",
    "Berseem",
    "Oats",
    "Sorghum",
    "Napier Grass",
  ];

  // Verification Status
  static const String statusPending = 'pending';
  static const String statusVerified = 'verified';
  static const String statusRejected = 'rejected';

  // Image Limits
  static const int maxCropImages = 3;
  static const int maxVerificationImages = 5;

  // Validation Rules
  static const int aadhaarLength = 12;
  static const int pincodeLength = 6;
  static const int phoneLength = 10;

  // AI Insights Messages
  static const List<String> aiInsights = [
    'Optimal time for fertilizer application',
    'Consider irrigation based on soil moisture',
    'Monitor for pest infestation',
    'Prepare for harvesting activities',
    'Weather conditions are favorable for growth',
    'Consider crop rotation for next season',
    'Soil testing recommended for nutrient balance',
    'Harvest timing looks optimal',
    'Consider organic pest control methods',
    'Crop health indicators are positive',
  ];

  // Location Defaults
  static const double defaultLatitude = 20.5937;
  static const double defaultLongitude = 78.9629;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Supported Languages
  static const Map<String, Map<String, String>> supportedLanguages = {
    'en': {'name': 'English', 'nativeName': 'English'},
    'hi': {'name': 'Hindi', 'nativeName': 'हिन्दी'},
    'mr': {'name': 'Marathi', 'nativeName': 'मराठी'},
  };
}
