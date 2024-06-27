import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Topics {
  List<List<dynamic>> globalChallenges() {
    List<List<dynamic>> globalChallenges = [
      [
        'Climate Change',
        'Climate Change and Environmental Degradation',
        Icons.wb_sunny,
        [
          'Definition',
          'Importance',
          'Causes',
          'Effects',
          'Mitigation Strategies',
          'International Agreements',
          'Technological Solutions',
          'Policy Interventions',
        ]
      ],
      [
        'Renewable Energy',
        'Energy Crisis and Transition to Renewable Energy',
        Icons.power,
        [
          'Definition',
          'Importance',
          'Current Energy Mix',
          'Renewable Energy Sources',
          'Challenges in Adoption',
          'Advantages of Renewable Energy',
          'Government Policies',
          'Future Prospects',
        ]
      ],
      [
        'Inequality',
        'Socioeconomic Inequality',
        Icons.compare_arrows,
        [
          'Definition',
          'Types of Inequality',
          'Causes',
          'Effects on Society',
          'Impact on Economic Growth',
          'Government Policies',
          'Social Interventions',
          'Global Efforts',
        ]
      ],
      [
        'Public Health',
        'Global Health Challenges',
        Icons.local_hospital,
        [
          'Definition',
          'Major Health Issues',
          'Global Health Organizations',
          'Disease Prevention',
          'Access to Healthcare',
          'Public Health Policies',
          'Healthcare Infrastructure',
          'International Collaboration',
        ]
      ],
      [
        'Food Security',
        'Food Security and Agriculture',
        Icons.restaurant,
        [
          'Definition',
          'Challenges in Food Production',
          'Food Distribution Issues',
          'Impact of Climate Change on Agriculture',
          'Government Policies',
          'Technological Innovations',
          'Sustainable Agriculture Practices',
          'Global Food Trade',
        ]
      ],
      [
        'Urbanization',
        'Population Growth and Urbanization',
        Icons.location_city,
        [
          'Definition',
          'Urbanization Trends',
          'Challenges of Urban Growth',
          'Urban Infrastructure',
          'Housing and Slums',
          'Transportation',
          'Urban Planning',
          'Smart Cities Initiative',
        ]
      ],
      [
        'Conflict',
        'Political Instability and Conflict',
        Icons.military_tech,
        [
          'Definition',
          'Causes of Political Instability',
          'Conflict Resolution Strategies',
          'Impact on Development',
          'International Peacekeeping',
          'Humanitarian Aid',
          'Peacebuilding Efforts',
          'Post-Conflict Reconstruction',
        ]
      ],
      [
        'Technology Divide',
        'Technological Disruption and Digital Divide',
        Icons.devices,
        [
          'Definition',
          'Digital Divide Issues',
          'Access to Technology',
          'Impact on Education',
          'Technological Innovation',
          'Government Policies',
          'Digital Literacy Programs',
          'International Technological Cooperation',
        ]
      ],
      [
        'Water Scarcity',
        'Water Scarcity and Management',
        Icons.waves,
        [
          'Definition',
          'Causes of Water Scarcity',
          'Effects on Agriculture and Industry',
          'Water Management Techniques',
          'Water Conservation',
          'International Water Agreements',
          'Desalination Technology',
          'Community Water Projects',
        ]
      ],
      [
        'Economic Stability',
        'Global Economic Stability',
        Icons.trending_up,
        [
          'Definition',
          'Factors Influencing Economic Stability',
          'Global Financial Systems',
          'Monetary and Fiscal Policies',
          'International Trade',
          'Income Inequality',
          'Financial Crises',
          'Sustainable Economic Growth',
        ]
      ],
      [
        'Education',
        'Education and Skills Development',
        Icons.school,
        [
          'Definition',
          'Challenges in Education',
          'Access to Education',
          'Quality of Education',
          'Educational Technologies',
          'Teacher Training',
          'Education Policy Reforms',
          'Global Education Goals',
        ]
      ],
      [
        'Biodiversity',
        'Biodiversity Loss',
        Icons.eco,
        [
          'Definition',
          'Causes of Biodiversity Loss',
          'Impact on Ecosystems',
          'Conservation Efforts',
          'Protected Areas',
          'Species Recovery Programs',
          'International Biodiversity Agreements',
          'Ecotourism and Biodiversity',
        ]
      ],
      [
        'Disaster Management',
        'Disaster Risk Reduction and Management',
        Icons.warning,
        [
          'Definition',
          'Types of Disasters',
          'Disaster Preparedness',
          'Early Warning Systems',
          'Emergency Response',
          'Recovery and Reconstruction',
          'Community Resilience',
          'Global Disaster Risk Reduction Frameworks',
        ]
      ],
      [
        'Biotechnology Ethics',
        'Ethical Use of Biotechnology',
        Icons.language,
        [
          'Definition',
          'Ethical Issues in Biotechnology',
          'Genetic Engineering Concerns',
          'Bioethics Regulations',
          'Impact on Environment',
          'Public Perception',
          'Global Biotechnology Policies',
          'Future of Biotechnology',
        ]
      ],
      [
        'Cultural Preservation',
        'Cultural Preservation and Globalization',
        Icons.public,
        [
          'Definition',
          'Cultural Heritage',
          'Globalization Impact on Culture',
          'Cultural Diversity',
          'Heritage Conservation',
          'Indigenous Rights',
          'Cultural Diplomacy',
          'International Cultural Agreements',
        ]
      ],
      [
        'Human Rights',
        'Human Rights and Social Justice',
        Icons.gavel,
        [
          'Definition',
          'Types of Human Rights',
          'Human Rights Violations',
          'Legal Frameworks',
          'Human Rights Advocacy',
          'Equality and Justice',
          'International Human Rights Standards',
          'Social Inclusion',
        ]
      ],
      [
        'Sustainable Consumption',
        'Sustainable Consumption and Production',
        Icons.eco,
        [
          'Definition',
          'Consumer Behavior',
          'Resource Efficiency',
          'Circular Economy',
          'Green Products and Services',
          'Corporate Sustainability',
          'Policy Instruments',
          'Global Sustainable Development Goals',
        ]
      ],
      [
        'Migration',
        'Migration and Refugee Crises',
        Icons.flight_takeoff,
        [
          'Definition',
          'Forced and Voluntary Migration',
          'Refugee Rights and Protection',
          'Integration Challenges',
          'Migration Policies',
          'Humanitarian Response',
          'International Cooperation',
          'Migration Trends and Statistics',
        ]
      ],
      [
        'Aging Population',
        'Aging Population and Healthcare for the Elderly',
        Icons.accessible_forward,
        [
          'Definition',
          'Healthcare Needs of Aging Population',
          'Elderly Care Services',
          'Social Security Systems',
          'Long-term Care',
          'Healthy Aging Initiatives',
          'Age-friendly Communities',
          'Global Aging Trends',
        ]
      ],
      [
        'Youth Empowerment',
        'Youth Unemployment and Empowerment',
        Icons.emoji_people,
        [
          'Definition',
          'Youth Employment Challenges',
          'Skills Development Programs',
          'Youth Participation in Decision-making',
          'Empowerment Strategies',
          'Youth Activism',
          'International Youth Policies',
          'Youth Opportunities and Innovations',
        ]
      ],
      [
        'Public Health Infrastructure',
        'Public Health Infrastructure',
        Icons.healing,
        [
          'Definition',
          'Healthcare Systems',
          'Infrastructure Development',
          'Healthcare Access',
          'Primary Healthcare Services',
          'Health Information Systems',
          'Emergency Response Capacity',
          'Health Infrastructure Funding',
        ]
      ],
      [
        'Mental Health Crisis',
        'Mental Health Crisis',
        Icons.sentiment_very_dissatisfied,
        [
          'Definition',
          'Prevalence of Mental Health Issues',
          'Stigma and Discrimination',
          'Mental Health Services',
          'Psychosocial Support',
          'Mental Health Policies',
          'Global Mental Health Initiatives',
          'Promotion of Mental Well-being',
        ]
      ],
      [
        'Ocean Management',
        'Ocean and Marine Resource Management',
        Icons.beach_access,
        [
          'Definition',
          'Ocean Conservation',
          'Marine Pollution',
          'Fisheries Management',
          'Marine Protected Areas',
          'Ocean Acidification',
          'Blue Economy',
          'International Marine Conservation Agreements',
        ]
      ],
      [
        'Corruption',
        'Corruption and Governance Issues',
        Icons.public_off,
        [
          'Definition',
          'Types of Corruption',
          'Impact on Development',
          'Anti-corruption Measures',
          'Transparency and Accountability',
          'Good Governance Practices',
          'International Anti-corruption Efforts',
          'Corruption Perception Index',
        ]
      ],
      [
        'Drug Abuse',
        'Drug Abuse and Illicit Trafficking',
        Icons.local_pharmacy,
        [
          'Definition',
          'Substance Abuse Issues',
          'Drug Trafficking Networks',
          'Prevention and Treatment Programs',
          'Harm Reduction Strategies',
          'International Drug Control Conventions',
          'Public Health Approaches',
          'Global Drug Use Trends',
        ]
      ],
      [
        'Nuclear Proliferation',
        'Nuclear Proliferation and Arms Control',
        Icons.radio,
        [
          'Definition',
          'Nuclear Weapons Programs',
          'Arms Control Agreements',
          'Non-proliferation Initiatives',
          'Nuclear Disarmament',
          'Nuclear Security',
          'International Atomic Energy Agency (IAEA)',
          'Nuclear Risk Reduction Measures',
        ]
      ],
      [
        'Digital Privacy',
        'Digital Privacy and Data Protection',
        Icons.security,
        [
          'Definition',
          'Data Privacy Concerns',
          'Cybersecurity Threats',
          'Regulatory Frameworks',
          'User Rights and Consent',
          'Encryption and Data Security',
          'International Data Protection Laws',
          'Privacy by Design',
        ]
      ],
      [
        'Ethical AI',
        'Ethical Implications of AI and Robotics',
        Icons.android,
        [
          'Definition',
          'Ethical Issues in AI',
          'Automation and Job Displacement',
          'AI Bias and Fairness',
          'AI Regulations',
          'Ethical AI Design Principles',
          'AI Transparency and Accountability',
          'Global AI Governance',
        ]
      ],
      [
        'Resource Management',
        'Resource Depletion and Waste Management',
        Icons.delete_forever,
        [
          'Definition',
          'Resource Depletion Challenges',
          'Waste Generation and Recycling',
          'Circular Economy Practices',
          'Sustainable Resource Management',
          'International Resource Sharing',
          'Natural Resource Conservation',
          'Waste-to-Energy Solutions',
        ]
      ],
      [
        'Deforestation',
        'Deforestation and Land Degradation',
        Icons.eco_outlined,
        [
          'Definition',
          'Causes of Deforestation',
          'Effects on Biodiversity',
          'Forest Conservation Efforts',
          'Reforestation Initiatives',
          'Forest Certification Programs',
          'Indigenous Land Rights',
          'Global Deforestation Trends',
        ]
      ],
      [
        'Urban Pollution',
        'Urban Pollution and Air Quality',
        Icons.cloud,
        [
          'Definition',
          'Types of Urban Pollution',
          'Air Quality Monitoring',
          'Pollution Control Technologies',
          'Impact on Public Health',
          'Urban Green Initiatives',
          'Transportation Solutions',
          'Global Pollution Standards',
        ]
      ],
      [
        'Sustainable Tourism',
        'Sustainable Tourism and Ecotourism',
        Icons.card_travel,
        [
          'Definition',
          'Benefits of Sustainable Tourism',
          'Ecotourism Practices',
          'Community Involvement',
          'Cultural Heritage Preservation',
          'Environmental Impact Assessment',
          'Tourism Certification Programs',
          'Global Sustainable Tourism Initiatives',
        ]
      ],
      [
        'Inclusive Economic Growth',
        'Inclusive Economic Growth and Decent Work',
        Icons.attach_money,
        [
          'Definition',
          'Challenges of Economic Inequality',
          'Inclusive Growth Policies',
          'Job Creation Strategies',
          'Labor Rights and Protections',
          'Economic Empowerment Programs',
          'Global Economic Trends',
          'Social Safety Nets',
        ]
      ],
      [
        'Supply Chain Resilience',
        'Global Supply Chain Resilience',
        Icons.gavel,
        [
          'Definition',
          'Supply Chain Vulnerabilities',
          'Resilience Strategies',
          'Supply Chain Transparency',
          'Global Trade Regulations',
          'Risk Management',
          'Disaster Preparedness',
          'International Supply Chain Networks',
        ]
      ],
      [
        'Financial Inclusion',
        'Fintech and Financial Inclusion',
        Icons.account_balance,
        [
          'Definition',
          'Barriers to Financial Inclusion',
          'Fintech Innovations',
          'Microfinance and Credit Services',
          'Digital Payment Solutions',
          'Financial Literacy Programs',
          'Regulatory Frameworks',
          'Global Financial Inclusion Initiatives',
        ]
      ],
      [
        'Pandemic Preparedness',
        'Pandemic Preparedness and Response',
        Icons.masks,
        [
          'Definition',
          'Pandemic Threats',
          'Disease Surveillance',
          'Public Health Emergency Response',
          'Vaccination Programs',
          'Global Health Security Agenda',
          'Medical Research and Development',
          'International Collaboration',
        ]
      ],
      [
        'Clean Energy',
        'Access to Clean Energy for All',
        Icons.flash_on,
        [
          'Definition',
          'Clean Energy Technologies',
          'Energy Access Challenges',
          'Renewable Energy Deployment',
          'Off-grid Solutions',
          'Energy Efficiency Measures',
          'Energy Poverty Alleviation',
          'Global Energy Transition Strategies',
        ]
      ],
      [
        'Child Labor',
        'Child Labor and Exploitation',
        Icons.child_friendly,
        [
          'Definition',
          'Causes of Child Labor',
          'Impact on Child Development',
          'Child Rights Protection',
          'Legal Frameworks',
          'Education and Child Labor',
          'Supply Chain Responsibility',
          'International Child Labor Standards',
        ]
      ],
      [
        'Human Trafficking',
        'Human Trafficking and Slavery',
        Icons.directions_walk,
        [
          'Definition',
          'Forms of Human Trafficking',
          'Victim Protection and Support',
          'Trafficking Routes',
          'Legal and Law Enforcement Measures',
          'Prevention Strategies',
          'International Anti-Trafficking Laws',
          'Human Trafficking Statistics',
        ]
      ],
      [
        'Endangered Species',
        'Protection of Endangered Species',
        Icons.pets,
        [
          'Definition',
          'Causes of Species Endangerment',
          'Conservation Efforts',
          'Habitat Protection',
          'Species Recovery Programs',
          'Wildlife Trade Regulation',
          'Ecological Restoration',
          'Global Endangered Species Lists',
        ]
      ],
      [
        'Marine Pollution',
        'Marine Pollution and Plastic Waste',
        Icons.opacity,
        [
          'Definition',
          'Sources of Marine Pollution',
          'Impact on Marine Ecosystems',
          'Plastic Waste Management',
          'Ocean Cleanup Initiatives',
          'International Marine Pollution Agreements',
          'Microplastics and Health Concerns',
          'Global Marine Pollution Monitoring',
        ]
      ],
      [
        'Conflict Minerals',
        'Conflict Minerals and Ethical Sourcing',
        Icons.change_history,
        [
          'Definition',
          'Conflict Mineral Extraction',
          'Ethical Sourcing Practices',
          'Supply Chain Transparency',
          'International Regulations',
          'Corporate Responsibility',
          'Impact on Conflict Areas',
          'Certification Programs',
        ]
      ],
      [
        'Cybersecurity Threats',
        'Cybersecurity Threats',
        Icons.security,
        [
          'Definition',
          'Types of Cyber Threats',
          'Cyber Defense Technologies',
          'Data Privacy Concerns',
          'Legal and Regulatory Frameworks',
          'Incident Response Planning',
          'International Cybersecurity Cooperation',
          'Cybersecurity Awareness Programs',
        ]
      ],
      [
        'Affordable Housing',
        'Access to Affordable Housing',
        Icons.home,
        [
          'Definition',
          'Housing Affordability Issues',
          'Homelessness',
          'Social Housing Programs',
          'Urban Housing Development',
          'Rural Housing Solutions',
          'Housing Finance Options',
          'Global Housing Policies',
        ]
      ],
      [
        'Migration Issues',
        'Legal and Illegal Migration',
        Icons.account_circle,
        [
          'Definition',
          'Migration Trends',
          'Causes of Migration',
          'Refugee Rights and Protections',
          'Integration Challenges',
          'Humanitarian Assistance',
          'International Migration Agreements',
          'Migration Data and Statistics',
        ]
      ],
      [
        'Agricultural Innovation',
        'Agricultural Innovation and Biotechnology',
        Icons.agriculture,
        [
          'Definition',
          'Biotechnological Advances',
          'Genetic Engineering in Agriculture',
          'Food Security Benefits',
          'Ethical Concerns in Agriculture',
          'Regulatory Frameworks',
          'Sustainable Farming Practices',
          'Global Agricultural Policies',
        ]
      ],
      [
        'Gender Equality',
        'Gender Equality and Women’s Empowerment',
        Icons.face,
        [
          'Definition',
          'Gender Inequality Issues',
          'Women\'s Rights',
          'Empowerment Strategies',
          'Gender Pay Gap',
          'Violence Against Women',
          'Gender-responsive Policies',
          'International Gender Equality Goals',
        ]
      ],
      [
        'Global Governance',
        'Global Governance and International Cooperation',
        Icons.group,
        [
          'Definition',
          'International Organizations',
          'Global Diplomacy',
          'Multilateralism',
          'Rule of Law',
          'United Nations System',
          'Global Governance Challenges',
          'Peace and Security Initiatives',
        ]
      ],
      [
        'Natural Disasters',
        'Resilience Against Natural Disasters',
        Icons.waves,
        [
          'Definition',
          'Types of Natural Disasters',
          'Disaster Risk Reduction Strategies',
          'Emergency Preparedness',
          'Disaster Response Coordination',
          'Post-disaster Recovery',
          'Community Resilience Building',
          'Global Disaster Risk Reduction Frameworks',
        ]
      ],
      [
        'Indigenous Rights',
        'Protection of Indigenous Rights',
        Icons.terrain,
        [
          'Definition',
          'Indigenous Peoples Issues',
          'Land Rights',
          'Cultural Heritage Preservation',
          'Self-determination',
          'Indigenous Knowledge Systems',
          'International Indigenous Rights Instruments',
          'Indigenous Representation and Advocacy',
        ]
      ],
    ];
    return globalChallenges;
  }

  String getApiKey() {
    String apiget = dotenv.env["API_KEY"]!;
    return apiget;
  }

  Future<String> usingGermini({required String what}) async {
    String greenresponse = "";
    final model = GenerativeModel(
      apiKey: getApiKey(),
      model: 'gemini-1.5-flash-latest',
    );
    try {
      final response = await model.generateContent([
        Content.text(
          what,
        )
      ]);
      greenresponse = response.text!;
    } catch (e) {
      greenresponse = 'Error: $e';
    }
    return greenresponse;
  }
    void bubbleSortAscending(List<List<dynamic>> list) {
    int n = list.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (list[j][0].compareTo(list[j + 1][0]) > 0) {
          var temp = list[j];
          list[j] = list[j + 1];
          list[j + 1] = temp;
        }
      }
    }
  }

  void bubbleSortDescending(List<List<dynamic>> list) {
    int n = list.length;
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        if (list[j][0].compareTo(list[j + 1][0]) < 0) {
          var temp = list[j];
          list[j] = list[j + 1];
          list[j + 1] = temp;
        }
      }
    }
  }

  final List<Map<String, String>> languages = [
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {'name': 'Chinese (PRC)', 'code': 'zh-cn'},
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-tw'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

}
