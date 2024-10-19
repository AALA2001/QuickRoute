/*
 Navicat Premium Dump SQL

 Source Server         : Local Connection
 Source Server Type    : MySQL
 Source Server Version : 90001 (9.0.1)
 Source Host           : localhost:3306
 Source Schema         : QuickRoute

 Target Server Type    : MySQL
 Target Server Version : 90001 (9.0.1)
 File Encoding         : 65001

 Date: 20/10/2024 03:19:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------

CREATE DATABASE quickroute;
USE quickroute;

DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of admin
-- ----------------------------
BEGIN;
INSERT INTO `admin` (`id`, `first_name`, `last_name`, `email`, `password`) VALUES (1, 'Hiranya', 'Semindi', 'hiranya@gmail.com', 'c48d831a0c0609ade8b22a2e153e6dfdb95e830c0393e5bfd66d2180c7d58fb82a58e9c70733490a425a0acb1685c10fdcbc52b97c4ea6a5133de2c74bfcebaa');
INSERT INTO `admin` (`id`, `first_name`, `last_name`, `email`, `password`) VALUES (2, 'Panda', 'Baba', 'virulnirmala@icloud.com', 'd94c1345b6d4f1e9cb83162042e9bf99e853d86880030d484e5ba68fe29c635e7d6abaf10d5ff2dcab2082fe1d8391783617f1c172bd373213a8a5f7a52524f4');
COMMIT;

-- ----------------------------
-- Table structure for country
-- ----------------------------
DROP TABLE IF EXISTS `country`;
CREATE TABLE `country` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=196 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of country
-- ----------------------------
BEGIN;
INSERT INTO `country` (`id`, `name`) VALUES (1, 'Afghanistan');
INSERT INTO `country` (`id`, `name`) VALUES (2, 'Albania');
INSERT INTO `country` (`id`, `name`) VALUES (3, 'Algeria');
INSERT INTO `country` (`id`, `name`) VALUES (4, 'Andorra');
INSERT INTO `country` (`id`, `name`) VALUES (5, 'Angola');
INSERT INTO `country` (`id`, `name`) VALUES (6, 'Antigua and Barbuda');
INSERT INTO `country` (`id`, `name`) VALUES (7, 'Argentina');
INSERT INTO `country` (`id`, `name`) VALUES (8, 'Armenia');
INSERT INTO `country` (`id`, `name`) VALUES (9, 'Australia');
INSERT INTO `country` (`id`, `name`) VALUES (10, 'Austria');
INSERT INTO `country` (`id`, `name`) VALUES (11, 'Azerbaijan');
INSERT INTO `country` (`id`, `name`) VALUES (12, 'Bahamas');
INSERT INTO `country` (`id`, `name`) VALUES (13, 'Bahrain');
INSERT INTO `country` (`id`, `name`) VALUES (14, 'Bangladesh');
INSERT INTO `country` (`id`, `name`) VALUES (15, 'Barbados');
INSERT INTO `country` (`id`, `name`) VALUES (16, 'Belarus');
INSERT INTO `country` (`id`, `name`) VALUES (17, 'Belgium');
INSERT INTO `country` (`id`, `name`) VALUES (18, 'Belize');
INSERT INTO `country` (`id`, `name`) VALUES (19, 'Benin');
INSERT INTO `country` (`id`, `name`) VALUES (20, 'Bhutan');
INSERT INTO `country` (`id`, `name`) VALUES (21, 'Bolivia');
INSERT INTO `country` (`id`, `name`) VALUES (22, 'Bosnia and Herzegovina');
INSERT INTO `country` (`id`, `name`) VALUES (23, 'Botswana');
INSERT INTO `country` (`id`, `name`) VALUES (24, 'Brazil');
INSERT INTO `country` (`id`, `name`) VALUES (25, 'Brunei');
INSERT INTO `country` (`id`, `name`) VALUES (26, 'Bulgaria');
INSERT INTO `country` (`id`, `name`) VALUES (27, 'Burkina Faso');
INSERT INTO `country` (`id`, `name`) VALUES (28, 'Burundi');
INSERT INTO `country` (`id`, `name`) VALUES (29, 'Cabo Verde');
INSERT INTO `country` (`id`, `name`) VALUES (30, 'Cambodia');
INSERT INTO `country` (`id`, `name`) VALUES (31, 'Cameroon');
INSERT INTO `country` (`id`, `name`) VALUES (32, 'Canada');
INSERT INTO `country` (`id`, `name`) VALUES (33, 'Central African Republic');
INSERT INTO `country` (`id`, `name`) VALUES (34, 'Chad');
INSERT INTO `country` (`id`, `name`) VALUES (35, 'Chile');
INSERT INTO `country` (`id`, `name`) VALUES (36, 'China');
INSERT INTO `country` (`id`, `name`) VALUES (37, 'Colombia');
INSERT INTO `country` (`id`, `name`) VALUES (38, 'Comoros');
INSERT INTO `country` (`id`, `name`) VALUES (39, 'Congo, Democratic Republic of the');
INSERT INTO `country` (`id`, `name`) VALUES (40, 'Congo, Republic of the');
INSERT INTO `country` (`id`, `name`) VALUES (41, 'Costa Rica');
INSERT INTO `country` (`id`, `name`) VALUES (42, 'Croatia');
INSERT INTO `country` (`id`, `name`) VALUES (43, 'Cuba');
INSERT INTO `country` (`id`, `name`) VALUES (44, 'Cyprus');
INSERT INTO `country` (`id`, `name`) VALUES (45, 'Czech Republic');
INSERT INTO `country` (`id`, `name`) VALUES (46, 'Denmark');
INSERT INTO `country` (`id`, `name`) VALUES (47, 'Djibouti');
INSERT INTO `country` (`id`, `name`) VALUES (48, 'Dominica');
INSERT INTO `country` (`id`, `name`) VALUES (49, 'Dominican Republic');
INSERT INTO `country` (`id`, `name`) VALUES (50, 'Ecuador');
INSERT INTO `country` (`id`, `name`) VALUES (51, 'Egypt');
INSERT INTO `country` (`id`, `name`) VALUES (52, 'El Salvador');
INSERT INTO `country` (`id`, `name`) VALUES (53, 'Equatorial Guinea');
INSERT INTO `country` (`id`, `name`) VALUES (54, 'Eritrea');
INSERT INTO `country` (`id`, `name`) VALUES (55, 'Estonia');
INSERT INTO `country` (`id`, `name`) VALUES (56, 'Eswatini');
INSERT INTO `country` (`id`, `name`) VALUES (57, 'Ethiopia');
INSERT INTO `country` (`id`, `name`) VALUES (58, 'Fiji');
INSERT INTO `country` (`id`, `name`) VALUES (59, 'Finland');
INSERT INTO `country` (`id`, `name`) VALUES (60, 'France');
INSERT INTO `country` (`id`, `name`) VALUES (61, 'Gabon');
INSERT INTO `country` (`id`, `name`) VALUES (62, 'Gambia');
INSERT INTO `country` (`id`, `name`) VALUES (63, 'Georgia');
INSERT INTO `country` (`id`, `name`) VALUES (64, 'Germany');
INSERT INTO `country` (`id`, `name`) VALUES (65, 'Ghana');
INSERT INTO `country` (`id`, `name`) VALUES (66, 'Greece');
INSERT INTO `country` (`id`, `name`) VALUES (67, 'Grenada');
INSERT INTO `country` (`id`, `name`) VALUES (68, 'Guatemala');
INSERT INTO `country` (`id`, `name`) VALUES (69, 'Guinea');
INSERT INTO `country` (`id`, `name`) VALUES (70, 'Guinea-Bissau');
INSERT INTO `country` (`id`, `name`) VALUES (71, 'Guyana');
INSERT INTO `country` (`id`, `name`) VALUES (72, 'Haiti');
INSERT INTO `country` (`id`, `name`) VALUES (73, 'Honduras');
INSERT INTO `country` (`id`, `name`) VALUES (74, 'Hungary');
INSERT INTO `country` (`id`, `name`) VALUES (75, 'Iceland');
INSERT INTO `country` (`id`, `name`) VALUES (76, 'India');
INSERT INTO `country` (`id`, `name`) VALUES (77, 'Indonesia');
INSERT INTO `country` (`id`, `name`) VALUES (78, 'Iran');
INSERT INTO `country` (`id`, `name`) VALUES (79, 'Iraq');
INSERT INTO `country` (`id`, `name`) VALUES (80, 'Ireland');
INSERT INTO `country` (`id`, `name`) VALUES (81, 'Israel');
INSERT INTO `country` (`id`, `name`) VALUES (82, 'Italy');
INSERT INTO `country` (`id`, `name`) VALUES (83, 'Jamaica');
INSERT INTO `country` (`id`, `name`) VALUES (84, 'Japan');
INSERT INTO `country` (`id`, `name`) VALUES (85, 'Jordan');
INSERT INTO `country` (`id`, `name`) VALUES (86, 'Kazakhstan');
INSERT INTO `country` (`id`, `name`) VALUES (87, 'Kenya');
INSERT INTO `country` (`id`, `name`) VALUES (88, 'Kiribati');
INSERT INTO `country` (`id`, `name`) VALUES (89, 'Korea, North');
INSERT INTO `country` (`id`, `name`) VALUES (90, 'Korea, South');
INSERT INTO `country` (`id`, `name`) VALUES (91, 'Kosovo');
INSERT INTO `country` (`id`, `name`) VALUES (92, 'Kuwait');
INSERT INTO `country` (`id`, `name`) VALUES (93, 'Kyrgyzstan');
INSERT INTO `country` (`id`, `name`) VALUES (94, 'Laos');
INSERT INTO `country` (`id`, `name`) VALUES (95, 'Latvia');
INSERT INTO `country` (`id`, `name`) VALUES (96, 'Lebanon');
INSERT INTO `country` (`id`, `name`) VALUES (97, 'Lesotho');
INSERT INTO `country` (`id`, `name`) VALUES (98, 'Liberia');
INSERT INTO `country` (`id`, `name`) VALUES (99, 'Libya');
INSERT INTO `country` (`id`, `name`) VALUES (100, 'Liechtenstein');
INSERT INTO `country` (`id`, `name`) VALUES (101, 'Lithuania');
INSERT INTO `country` (`id`, `name`) VALUES (102, 'Luxembourg');
INSERT INTO `country` (`id`, `name`) VALUES (103, 'Madagascar');
INSERT INTO `country` (`id`, `name`) VALUES (104, 'Malawi');
INSERT INTO `country` (`id`, `name`) VALUES (105, 'Malaysia');
INSERT INTO `country` (`id`, `name`) VALUES (106, 'Maldives');
INSERT INTO `country` (`id`, `name`) VALUES (107, 'Mali');
INSERT INTO `country` (`id`, `name`) VALUES (108, 'Malta');
INSERT INTO `country` (`id`, `name`) VALUES (109, 'Marshall Islands');
INSERT INTO `country` (`id`, `name`) VALUES (110, 'Mauritania');
INSERT INTO `country` (`id`, `name`) VALUES (111, 'Mauritius');
INSERT INTO `country` (`id`, `name`) VALUES (112, 'Mexico');
INSERT INTO `country` (`id`, `name`) VALUES (113, 'Micronesia');
INSERT INTO `country` (`id`, `name`) VALUES (114, 'Moldova');
INSERT INTO `country` (`id`, `name`) VALUES (115, 'Monaco');
INSERT INTO `country` (`id`, `name`) VALUES (116, 'Mongolia');
INSERT INTO `country` (`id`, `name`) VALUES (117, 'Montenegro');
INSERT INTO `country` (`id`, `name`) VALUES (118, 'Morocco');
INSERT INTO `country` (`id`, `name`) VALUES (119, 'Mozambique');
INSERT INTO `country` (`id`, `name`) VALUES (120, 'Myanmar');
INSERT INTO `country` (`id`, `name`) VALUES (121, 'Namibia');
INSERT INTO `country` (`id`, `name`) VALUES (122, 'Nauru');
INSERT INTO `country` (`id`, `name`) VALUES (123, 'Nepal');
INSERT INTO `country` (`id`, `name`) VALUES (124, 'Netherlands');
INSERT INTO `country` (`id`, `name`) VALUES (125, 'New Zealand');
INSERT INTO `country` (`id`, `name`) VALUES (126, 'Nicaragua');
INSERT INTO `country` (`id`, `name`) VALUES (127, 'Niger');
INSERT INTO `country` (`id`, `name`) VALUES (128, 'Nigeria');
INSERT INTO `country` (`id`, `name`) VALUES (129, 'North Macedonia');
INSERT INTO `country` (`id`, `name`) VALUES (130, 'Norway');
INSERT INTO `country` (`id`, `name`) VALUES (131, 'Oman');
INSERT INTO `country` (`id`, `name`) VALUES (132, 'Pakistan');
INSERT INTO `country` (`id`, `name`) VALUES (133, 'Palau');
INSERT INTO `country` (`id`, `name`) VALUES (134, 'Panama');
INSERT INTO `country` (`id`, `name`) VALUES (135, 'Papua New Guinea');
INSERT INTO `country` (`id`, `name`) VALUES (136, 'Paraguay');
INSERT INTO `country` (`id`, `name`) VALUES (137, 'Peru');
INSERT INTO `country` (`id`, `name`) VALUES (138, 'Philippines');
INSERT INTO `country` (`id`, `name`) VALUES (139, 'Poland');
INSERT INTO `country` (`id`, `name`) VALUES (140, 'Portugal');
INSERT INTO `country` (`id`, `name`) VALUES (141, 'Qatar');
INSERT INTO `country` (`id`, `name`) VALUES (142, 'Romania');
INSERT INTO `country` (`id`, `name`) VALUES (143, 'Russia');
INSERT INTO `country` (`id`, `name`) VALUES (144, 'Rwanda');
INSERT INTO `country` (`id`, `name`) VALUES (145, 'Saint Kitts and Nevis');
INSERT INTO `country` (`id`, `name`) VALUES (146, 'Saint Lucia');
INSERT INTO `country` (`id`, `name`) VALUES (147, 'Saint Vincent and the Grenadines');
INSERT INTO `country` (`id`, `name`) VALUES (148, 'Samoa');
INSERT INTO `country` (`id`, `name`) VALUES (149, 'San Marino');
INSERT INTO `country` (`id`, `name`) VALUES (150, 'Sao Tome and Principe');
INSERT INTO `country` (`id`, `name`) VALUES (151, 'Saudi Arabia');
INSERT INTO `country` (`id`, `name`) VALUES (152, 'Senegal');
INSERT INTO `country` (`id`, `name`) VALUES (153, 'Serbia');
INSERT INTO `country` (`id`, `name`) VALUES (154, 'Seychelles');
INSERT INTO `country` (`id`, `name`) VALUES (155, 'Sierra Leone');
INSERT INTO `country` (`id`, `name`) VALUES (156, 'Singapore');
INSERT INTO `country` (`id`, `name`) VALUES (157, 'Slovakia');
INSERT INTO `country` (`id`, `name`) VALUES (158, 'Slovenia');
INSERT INTO `country` (`id`, `name`) VALUES (159, 'Solomon Islands');
INSERT INTO `country` (`id`, `name`) VALUES (160, 'Somalia');
INSERT INTO `country` (`id`, `name`) VALUES (161, 'South Africa');
INSERT INTO `country` (`id`, `name`) VALUES (162, 'Spain');
INSERT INTO `country` (`id`, `name`) VALUES (163, 'Sri Lanka');
INSERT INTO `country` (`id`, `name`) VALUES (164, 'Sudan');
INSERT INTO `country` (`id`, `name`) VALUES (165, 'Suriname');
INSERT INTO `country` (`id`, `name`) VALUES (166, 'Sweden');
INSERT INTO `country` (`id`, `name`) VALUES (167, 'Switzerland');
INSERT INTO `country` (`id`, `name`) VALUES (168, 'Syria');
INSERT INTO `country` (`id`, `name`) VALUES (169, 'Taiwan');
INSERT INTO `country` (`id`, `name`) VALUES (170, 'Tajikistan');
INSERT INTO `country` (`id`, `name`) VALUES (171, 'Tanzania');
INSERT INTO `country` (`id`, `name`) VALUES (172, 'Thailand');
INSERT INTO `country` (`id`, `name`) VALUES (173, 'Timor-Leste');
INSERT INTO `country` (`id`, `name`) VALUES (174, 'Togo');
INSERT INTO `country` (`id`, `name`) VALUES (175, 'Tonga');
INSERT INTO `country` (`id`, `name`) VALUES (176, 'Trinidad and Tobago');
INSERT INTO `country` (`id`, `name`) VALUES (177, 'Tunisia');
INSERT INTO `country` (`id`, `name`) VALUES (178, 'Turkey');
INSERT INTO `country` (`id`, `name`) VALUES (179, 'Turkmenistan');
INSERT INTO `country` (`id`, `name`) VALUES (180, 'Tuvalu');
INSERT INTO `country` (`id`, `name`) VALUES (181, 'Uganda');
INSERT INTO `country` (`id`, `name`) VALUES (182, 'Ukraine');
INSERT INTO `country` (`id`, `name`) VALUES (183, 'United Arab Emirates');
INSERT INTO `country` (`id`, `name`) VALUES (184, 'United Kingdom');
INSERT INTO `country` (`id`, `name`) VALUES (185, 'United States');
INSERT INTO `country` (`id`, `name`) VALUES (186, 'Uruguay');
INSERT INTO `country` (`id`, `name`) VALUES (187, 'Uzbekistan');
INSERT INTO `country` (`id`, `name`) VALUES (188, 'Vanuatu');
INSERT INTO `country` (`id`, `name`) VALUES (189, 'Vatican City');
INSERT INTO `country` (`id`, `name`) VALUES (190, 'Venezuela');
INSERT INTO `country` (`id`, `name`) VALUES (191, 'Vietnam');
INSERT INTO `country` (`id`, `name`) VALUES (192, 'Yemen');
INSERT INTO `country` (`id`, `name`) VALUES (193, 'Zambia');
INSERT INTO `country` (`id`, `name`) VALUES (194, 'Zimbabwe');
INSERT INTO `country` (`id`, `name`) VALUES (195, 'USA');
COMMIT;

-- ----------------------------
-- Table structure for destination_location
-- ----------------------------
DROP TABLE IF EXISTS `destination_location`;
CREATE TABLE `destination_location` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `image` text NOT NULL,
  `overview` text NOT NULL,
  `tour_type_id` int NOT NULL,
  `destinations_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_destination_location_tour_type1_idx` (`tour_type_id`),
  KEY `fk_destination_location_destinations1_idx` (`destinations_id`),
  CONSTRAINT `fk_destination_location_destinations1` FOREIGN KEY (`destinations_id`) REFERENCES `destinations` (`id`),
  CONSTRAINT `fk_destination_location_tour_type1` FOREIGN KEY (`tour_type_id`) REFERENCES `tour_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of destination_location
-- ----------------------------
BEGIN;
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (1, 'Ruwanwelisaya Stupa', 'locations/Ruwanwelisaya_Stupa_14026021877.png', 'Ruwanwelisaya is one of the most significant stupas in Sri Lanka, revered for its architectural grandeur and religious importance. It is believed to contain sacred relics of the Buddha. Visitors can walk around the stupa, meditate, and learn about its rich history.\r\nRuwanweli Seya a feast of civil engineering marvel, enshrining the relics of Lord Buddha or did it have a higher purpose? Designed by Arhants or enlightened ones themselves archaeologists and investigators inquire the greater purpose of a stupa whose construction was predicted by Buddha and was awaited by Arhants, gods and humans.\r\n\r\nBuilt nearly 2500 years ago,accomplishing a prediction made by Lord Buddha himself, Ruwanweli Seya or the pagoda of golden dust, was one of the largest structures in the ancient world, standing 103 m tall with a circumference of 290 m.\r\n\r\nAlso known as the Mahathupa, Swarnamali Chaitya, Suvarnamali Mahaceti and Rathnamali Dagaba, the stupa is an engineering feast and a testimony to the engineering capabilities of the ancient Sri Lankans.', 2, 1);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (2, 'Jaya Sri Maha Bodhi', 'locations/Jaya_Sri Maha Bodhi_14746385334.png', 'The Jaya Sri Maha Bodhi is a sacred fig tree, said to be grown from a branch of the original Bodhi tree under which Buddha attained enlightenment. It is one of the most venerated sites in Sri Lanka, where devotees gather to offer prayers.\r\n\r\nJaya Sri Maha Bodhi is a historical sacred bo tree (Ficus religiosa) in the Mahamewuna Garden in historical city of Anuradhapura, Sri Lanka. This is believed to be a tree grown from a cutting of the southern branch from the historical sacred bo tree, Sri Maha Bodhi, which was destroyed during Emperor Ashoka the Great time, at Buddha Gaya in India, under which Siddhartha Gautama (Buddha) attained Enlightenment. \r\n\r\nThe Buddhist nun Sangamitta Maha Theri, a daughter of Indian Emperor Ashoka, in 288 BC, brought the tree cutting to Sri Lanka during the reign of Sinhalese King Devanampiya Tissa. At more than 2,300 years old, it is the oldest living human-planted tree in the world with a known planting date. The Mahavamsa, or the great chronicle of the Sinhalese, provides an elaborate account of the establishment of the Jaya Siri Maha Bodhi on the Island and the subsequent development of the site as a major Buddhist pilgrimage site.', 7, 1);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (3, ' Fushimi Inari Shrine', 'locations/_Fushimi Inari Shrine_151531137879.png', 'Famous for its thousands of red torii gates, Fushimi Inari Shrine is one of Kyoto\'s most iconic sites. The shrine is dedicated to Inari, the Shinto god of rice and agriculture. Visitors can hike the trails that wind through the forest, passing many smaller shrines.\r\n\r\nFushimi Inari Shrine (伏見稲荷大社, Fushimi Inari Taisha) is an important Shinto shrine in southern Kyoto. It is famous for its thousands of vermilion torii gates, which straddle a network of trails behind its main buildings. The trails lead into the wooded forest of the sacred Mount Inari, which stands at 233 meters and belongs to the shrine grounds.\r\n\r\nFushimi Inari is the most important of several thousands of shrines dedicated to Inari, the Shinto god of rice. Foxes are thought to be Inari\'s messengers, resulting in many fox statues across the shrine grounds. Fushimi Inari Shrine has ancient origins, predating the capital\'s move to Kyoto in 794.\r\n', 4, 2);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (4, 'Kinkaku-ji (Golden Pavilion)', 'locations/Kinkaku-ji_(Golden Pavilion)_152448760123.png', 'Kinkakuji (金閣寺, Golden Pavilion) is a Zen temple in northern Kyoto whose top two floors are completely covered in gold leaf. Formally known as Rokuonji, the temple was the retirement villa of the shogun Ashikaga Yoshimitsu, and according to his will it became a Zen temple of the Rinzai sect after his death in 1408. Kinkakuji was the inspiration for the similarly named Ginkakuji (Silver Pavilion), built by Yoshimitsu\'s grandson, Ashikaga Yoshimasa, on the other side of the city a few decades later.\r\n\r\nKinkakuji is an impressive structure built overlooking a large pond, and is the only building left of Yoshimitsu\'s former retirement complex. It has burned down numerous times throughout its history including twice during the Onin War, a civil war that destroyed much of Kyoto; and once again more recently in 1950 when it was set on fire by a fanatic monk. The present structure was rebuilt in 1955.', 11, 2);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (5, 'Colosseum', 'locations/Colosseum_152949913648.png', 'The Flavian Amphitheatre, more commonly known as the Colosseum, stands in the archaeological heart of Rome and welcomes large numbers of visitors daily, attracted by the fascination of its history and its complex architecture.\r\n\r\nThe building became known as the Colosseum because of a colossal statue that stood nearby. It was built in the 1st century CE at the behest of the emperors of the Flavian dynasty. Until the end of the ancient period, it was used to present spectacles of great popular appeal, such as animal hunts and gladiatorial games. The building was, and still remains today, a spectacle in itself. It is the largest amphitheatre in the world, capable of presenting surprisingly complex stage machinery, as well as services for spectators.\r\n\r\nA symbol of the splendour of the empire, the Amphitheatre has changed its appearance and its function over the centuries, presenting itself as a structured space but open to the Roman community.', 4, 3);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (6, 'Vatican Museums', 'locations/Vatican_Museums_15335699824.png', 'The Vatican Museums are the public museums of Vatican City, enclave of Rome. They display works from the immense collection amassed by the Catholic Church and the papacy throughout the centuries, including several of the most well-known Roman sculptures and most important masterpieces of Renaissance art in the world. The museums contain roughly 70,000 works, of which 20,000 are on display, and currently employs 640 people who work in 40 different administrative, scholarly, and restoration departments.\r\n\r\nPope Julius II founded the museums in the early 16th century. The Sistine Chapel, with its ceiling and altar wall decorated by Michelangelo, and the Stanze di Raffaello (decorated by Raphael) are on the visitor route through the Vatican Museums.\r\n\r\nIn 2023, the Vatican Museums were visited by 6.8 million people.They ranked second in the list of most-visited art museums in the world after the Louvre, and third on the list of most-visited museums.', 2, 3);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (7, ' Great Pyramid of Giza', 'locations/_Great Pyramid of Giza_153535463178.png', 'Pyramids of Giza, three 4th-dynasty (c. 2575–c. 2465 bce) pyramids erected on a rocky plateau on the west bank of the Nile River near Al-Jīzah (Giza) in northern Egypt. In ancient times they were included among the Seven Wonders of the World. The ancient ruins of the Memphis area, including the Pyramids of Giza, Ṣaqqārah, Dahshūr, Abū Ruwaysh, and Abū Ṣīr, were collectively designated a UNESCO World Heritage site in 1979.\r\n\r\nThe designations of the pyramids—Khufu, Khafre, and Menkaure—correspond to the kings for whom they were built. The northernmost and oldest pyramid of the group was built for Khufu (Greek: Cheops), the second king of the 4th dynasty. Called the Great Pyramid, it is the largest of the three, the length of each side at the base averaging 755.75 feet (230 metres) and its original height being 481.4 feet (147 metres). \r\n\r\nThe middle pyramid was built for Khafre (Greek: Chephren), the fourth of the eight kings of the 4th dynasty; the structure measures 707.75 feet (216 metres) on each side and was originally 471 feet (143 metres) high. The southernmost and last pyramid to be built was that of Menkaure (Greek: Mykerinus), the fifth king of the 4th dynasty; each side measures 356.5 feet (109 metres), and the structure’s completed height was 218 feet (66 metres).', 4, 4);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (8, 'Egyptian Museum', 'locations/Egyptian_Museum_153929393029.png', 'The Egyptian Museum is the oldest archaeological museum in the Middle East, and houses the largest collection of Pharaonic antiquities in the world. The museum displays an extensive collection spanning from the Predynastic Period to the Greco-Roman Era.\r\n\r\nThe architect of the building was selected through an international competition in 1895, which was the first of its kind, and was won by the French architect, Marcel Dourgnon. The museum was inaugurated in 1902 by Khedive Abbas Helmy II, and has become a historic landmark in downtown Cairo, and home to some of the world’s most magnificent ancient masterpieces.\r\n\r\nAmong the museum’s unrivaled collection are the complete burials of Yuya and Thuya, Psusennes I and the treasures of Tanis, and the Narmer Palette commemorating the unification of Upper and Lower Egypt under one king, which is also among the museum’s invaluable artifacts. The museum also houses the splendid statues of the great kings Khufu, Khafre, and Menkaure, the builders of the pyramids at the Giza plateau. An extensive collection of papyri, sarcophagi and jewelry, among other objects, completes this uniquely expansive museum.', 2, 4);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (9, 'Sydney Opera House', 'locations/Sydney_Opera House_154212809686.png', 'The Sydney Opera House is a multi-venue performing arts centre in Sydney, New South Wales, Australia. Located on the foreshore of Sydney Harbour, it is widely regarded as one of the world\'s most famous and distinctive buildings and a masterpiece of 20th-century architecture.\r\n\r\nDesigned by Danish architect Jørn Utzon and completed by an Australian architectural team headed by Peter Hall, the building was formally opened by Queen Elizabeth II on 20 October 1973, 16 years after Utzon\'s 1957 selection as winner of an international design competition. The Government of New South Wales, led by the premier, Joseph Cahill, authorised work to begin in 1958 with Utzon directing construction. The government\'s decision to build Utzon\'s design is often overshadowed by circumstances that followed, including cost and scheduling overruns as well as the architect\'s ultimate resignation.\r\n\r\nThe building and its surrounds occupy the whole of Bennelong Point on Sydney Harbour, between Sydney Cove and Farm Cove, adjacent to the Sydney central business district and the Royal Botanic Gardens, and near to the Sydney Harbour Bridge.', 11, 5);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (10, 'Bondi Beach', 'locations/Bondi_Beach_154730137772.png', 'Bondi Beach is a popular beach and the name of the surrounding suburb in Sydney, New South Wales, Australia. Bondi Beach is located 7 kilometres (4 miles) east of the Sydney central business district, in the local government area of Waverley Council, in the Eastern Suburbs. In the 2021 Australian census it had a population of 11,513 residents. Its postcode is 2026. Bondi, North Bondi and Bondi Junction are neighbouring suburbs. Bondi Beach is one of the most visited tourist sites in Australia, and the location of two hit TV series Bondi Rescue and Bondi Vet.\r\n\r\nBondi Beach is about 1 kilometre (0.6 mi) long and receives many visitors throughout the year. Surf Life Saving Australia gave different hazard ratings to areas of Bondi Beach in 2004. While the northern end has been rated a gentle 4 (with 10 as the most hazardous), the southern side is rated as a 7 due to a famous rip current known as the \"Backpackers\' Rip\" because of its proximity to the bus stop. Many backpackers and tourists do not realise that the flat, smooth water is a dangerous rip current, and tourists can be unwilling to walk the length of the beach to safer swimming. The south end of the beach is generally reserved for surfboard riding. Yellow and red flags define safe swimming areas, and visitors are advised to swim between them.', 14, 5);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (11, 'Hanifaru Bay', 'locations/Hanifaru_Bay_17156257702.png', 'Swimming amongst the feeding aggregations of manta rays and whale sharks at Hanifaru Bay is one of the most exciting and mind-blowing thing you can do. There are only handful of places in the world where visitors can get so close to so many manta rays, snorkelling alongside them as they barrel-rolling and ‘fly’ in formation through the dense plankton - a behaviour that has become known as cyclone feeding.\r\n\r\nHanifaru was long known to local fishermen who would travel to the site to hunt whale sharks feeding in the bay alongside the manta rays. In the early 1990s dive safari boats began to visit the bay but given the exceptional nature of the experience, word soon got out and it wasn’t long before Hanifaru Bay became crammed with boats and divers every day - far too many for the tiny bay and its rays to sustain.\r\n\r\nQuickly realising that dive tourism at the site was getting out of control, the government stepped in and after several dramatic twists and turns, Hanifaru Bay was declared a Marine Protected Area in 2009, then incorporated into the UNESCO World Biosphere Reserve in 2011.', 1, 6);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (12, 'Oia Village', 'locations/Oia_Village_171810229792.png', 'Oia is the most beautiful village of Santorini that recently started looking like a glamorous town, every day gathering thousands of people longing for seeing the famous Oia sunsets.If you have time to visit just one place in the island – choose Oia. That’s what you’ve been dreaming of for so many years looking at the pictures of the white churches with bright blue domes.Oia is located 11 km away from Fira and is a pedestrian town. Most of the visitors come here to admire its unique architecture, captains’ houses, Blue Domes, cave houses and the sunset.You can see crowds of people here any time of the day, for it’s a must to see if you are in Santorini. Otherwise you’ll have to come back!\r\n\r\nOia is famous for its chic and expensive restaurants and a great shopping, too. The truth is that in this town you can find all the beautiful, quality, expensive and exclusive goods. Santorini is being visited by all the famous and important personalities of the whole world regularly, therefore every expensive world famous brand is presented here.\r\n\r\nThis town hosts an incredible number of hotels, although most of them you do not notice thinking these are just the houses of the locals.The whole place is built along the Cliffside. Do not expect to swim in the sea if you stay here – the beaches are located on a different, flat side of the island.Oia is the only settlement of the island that can boast of a marble avenue crossing its whole length.  ', 11, 7);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (13, 'Times Square', 'locations/Times_Square_1725419173.png', 'Times Square is a major commercial intersection, tourist destination, entertainment hub, and neighborhood in the Midtown Manhattan section of New York City. It is formed by the junction of Broadway, Seventh Avenue, and 42nd Street. Together with adjacent Duffy Square, Times Square is a bowtie-shaped plaza five blocks long between 42nd and 47th Streets.\r\n\r\nTimes Square is brightly lit by numerous digital billboards and advertisements as well as businesses offering 24/7 service. One of the world\'s busiest pedestrian areas, it is also the hub of the Broadway Theater District and a major center of the world\'s entertainment industry. Times Square is one of the world\'s most visited tourist attractions, drawing an estimated 50 million visitors annually. Approximately 330,000 people pass through Times Square daily, many of them tourists, while over 460,000 pedestrians walk through Times Square on its busiest days. The Times Square–42nd Street and 42nd Street–Port Authority Bus Terminal stations have consistently ranked as the busiest in the New York City Subway system, transporting more than 200,000 passengers daily.', 21, 8);
INSERT INTO `destination_location` (`id`, `title`, `image`, `overview`, `tour_type_id`, `destinations_id`) VALUES (14, 'The Great Wall of China', 'locations/The_Great Wall of China_192811310891.png', 'The Great Wall of China is one of the most iconic landmarks in the world, stretching over 13,000 miles across northern China. Originally built to protect against invasions, its construction began as early as the 7th century BC and continued for centuries, incorporating various materials like earth, wood, bricks, and stone.\r\nThe wall features watchtowers, fortresses, and barracks, showcasing impressive ancient engineering. It winds through diverse landscapes, including mountains, deserts, and grasslands, and is a UNESCO World Heritage Site, symbolizing China\'s historical strength and perseverance. Today, the Great Wall attracts millions of visitors, offering breathtaking views and a glimpse into the country\'s rich history.\r\n\r\nArchitectural Features\r\n\r\nThe wall varies in design depending on the region, with some sections made from tamped earth, while others are constructed from bricks or stone. Features like watchtowers and beacon towers were strategically placed at intervals, allowing for communication and defense against invaders. These structures also provided vantage points for soldiers to spot approaching threats.\r\n\r\nHistorical Significance\r\n\r\nThe Great Wall served multiple purposes beyond military defense. It facilitated the control of trade routes, particularly along the Silk Road, and helped to regulate immigration and emigration. It also symbolized the unification of various Chinese states under a centralized government.\r\n\r\nCultural Impact\r\n\r\nThroughout its history, the Great Wall has inspired countless stories, songs, and artworks. It represents national pride and is often seen as a symbol of perseverance and strength. It reflects the ingenuity of ancient Chinese civilization and its capacity to overcome natural obstacles.\r\n\r\nModern Day\r\n\r\nToday, the Great Wall is a major tourist destination, with sections like Badaling and Mutianyu being particularly popular for their accessibility and stunning views. Preservation efforts are ongoing to protect this historical monument from erosion and damage due to tourism.\r\n\r\nMyth and Legend\r\n\r\nLegends surrounding the Great Wall abound, including tales of soldiers who died defending it and stories of those who were buried within its walls. These narratives add a layer of mystique and cultural richness to the wall’s history.\r\nIn summary, the Great Wall of China is not only an architectural marvel but also a profound symbol of Chinese culture, history, and resilience. Its grandeur and historical importance continue to captivate people from around the world.', 4, 9);
COMMIT;

-- ----------------------------
-- Table structure for destinations
-- ----------------------------
DROP TABLE IF EXISTS `destinations`;
CREATE TABLE `destinations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `country_id` int NOT NULL,
  `image` text NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_destinations_country1_idx` (`country_id`),
  CONSTRAINT `fk_destinations_country1` FOREIGN KEY (`country_id`) REFERENCES `country` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of destinations
-- ----------------------------
BEGIN;
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (1, 'Anuradhapura', 163, 'destinations/Anuradhapura_135335284646.png', 'Anuradhapura is an ancient city in Sri Lanka known for its historical ruins and significant Buddhist sites.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (2, 'Kyoto', 84, 'destinations/Kyoto_123515787461.png', 'Kyoto is a city in Japan famous for its classical Buddhist temples, beautiful gardens, imperial palaces, and traditional wooden houses.\r\n');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (3, 'Rome', 82, 'destinations/Rome_123738959999.png', 'Rome is Italy\'s capital, known for its nearly 3,000 years of globally influential art, architecture, and culture.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (4, 'Cairo', 51, 'destinations/Cairo_123828977059.png', 'Cairo is the sprawling capital of Egypt, known for its proximity to the famous Giza Pyramids and its rich cultural heritage.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (5, 'Sydney', 9, 'destinations/Sydney_123957333332.png', 'Sydney is a major city in Australia, known for its Sydney Opera House, Harbour Bridge, and beautiful beaches.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (6, 'Maldives Paradise', 106, 'destinations/Maldives_Paradise_17156505065.png', 'The Maldives is an idyllic paradise with crystal-clear waters, white sandy beaches, and luxurious overwater bungalows. Known for its stunning coral reefs, it is the perfect destination for snorkeling, diving, and relaxation. Experience the vibrant marine life and enjoy sunset dinners on the beach.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (7, 'Santorini Island', 66, 'destinations/Santorini_Island_171930478481.png', 'Santorini is famous for its stunning sunsets, whitewashed buildings with blue domes, and beautiful beaches. Explore the charming villages, indulge in local cuisine, and visit ancient ruins. This picturesque island offers a unique blend of relaxation and adventure, making it a perfect getaway.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (8, 'New York City', 195, 'destinations/New_York City_17937015459.png', 'New York City is a bustling metropolis known for its iconic skyline, world-class museums, and vibrant culture. Visit famous landmarks like Times Square, Central Park, and the Statue of Liberty. Experience the city\'s diverse neighborhoods, indulge in gourmet food, and catch a Broadway show for an unforgettable trip.');
INSERT INTO `destinations` (`id`, `title`, `country_id`, `image`, `description`) VALUES (9, 'Beijing', 36, 'destinations/Great_Wall of China_1920266485.png', 'Beijing, China’s sprawling capital, has history stretching back 3 millennia.');
COMMIT;

-- ----------------------------
-- Table structure for offers
-- ----------------------------
DROP TABLE IF EXISTS `offers`;
CREATE TABLE `offers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_Date` datetime NOT NULL,
  `to_Date` datetime NOT NULL,
  `title` varchar(100) NOT NULL,
  `image` text NOT NULL,
  `destination_location_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_offers_destination_location1_idx` (`destination_location_id`),
  CONSTRAINT `fk_offers_destination_location1` FOREIGN KEY (`destination_location_id`) REFERENCES `destination_location` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of offers
-- ----------------------------
BEGIN;
INSERT INTO `offers` (`id`, `from_Date`, `to_Date`, `title`, `image`, `destination_location_id`) VALUES (1, '2024-10-16 07:30:59', '2024-10-18 17:30:59', '2-Day Guided Tour with Meditation Sessions and Cultural Insight', 'offers/2-Day_Guided Tour with Meditation Sessions and Cultural Insight_181235023563.png', 1);
INSERT INTO `offers` (`id`, `from_Date`, `to_Date`, `title`, `image`, `destination_location_id`) VALUES (2, '2024-10-15 10:30:59', '2024-10-25 14:35:59', '3-Day Exploration of Fushimi Inari with Traditional Tea Ceremony', 'offers/3-Day_Exploration of Fushimi Inari with Traditional Tea Ceremony_18743788729.png', 3);
INSERT INTO `offers` (`id`, `from_Date`, `to_Date`, `title`, `image`, `destination_location_id`) VALUES (3, '2024-10-15 12:30:59', '2024-10-18 23:41:59', '2-Day Tour with Skip-the-Line Access and Expert Guide', 'offers/2-Day_Tour with Skip-the-Line Access and Expert Guide_181152427242.png', 5);
INSERT INTO `offers` (`id`, `from_Date`, `to_Date`, `title`, `image`, `destination_location_id`) VALUES (4, '2024-10-15 09:30:59', '2024-10-18 09:30:59', '3-Day Package with VIP Performance Tickets and Guided Backstage', 'offers/3-Day_Package with VIP Performance Tickets and Guided Backstage_213623757839.png', 9);
INSERT INTO `offers` (`id`, `from_Date`, `to_Date`, `title`, `image`, `destination_location_id`) VALUES (5, '2024-10-20 10:30:59', '2024-10-22 10:30:59', 'Great Wall Adventure Package – Buy One Ticket, Get the Second Half Price!', 'offers/Great_Wall Adventure Package – Buy One Ticket, Get the Second Half Price!_194329822541.png', 14);
COMMIT;

-- ----------------------------
-- Table structure for plan_has_des
-- ----------------------------
DROP TABLE IF EXISTS `plan_has_des`;
CREATE TABLE `plan_has_des` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trip_plan_id` int DEFAULT NULL,
  `destination_location_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_trip_plan_has_users_trip_destinations_trip_plan1_idx` (`trip_plan_id`),
  KEY `fk_plan_has_des_destination_location1_idx` (`destination_location_id`),
  CONSTRAINT `fk_plan_has_des_destination_location1` FOREIGN KEY (`destination_location_id`) REFERENCES `destination_location` (`id`),
  CONSTRAINT `fk_trip_plan_has_users_trip_destinations_trip_plan1` FOREIGN KEY (`trip_plan_id`) REFERENCES `trip_plan` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of plan_has_des
-- ----------------------------
BEGIN;
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (1, 17, 3);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (2, 17, 4);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (3, 17, 7);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (4, 17, 6);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (5, 19, 1);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (6, 19, 2);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (7, 18, 9);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (8, 18, 11);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (9, 18, 14);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (10, 18, 13);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (11, 18, 1);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (12, 18, 3);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (13, 18, 7);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (14, 18, 8);
INSERT INTO `plan_has_des` (`id`, `trip_plan_id`, `destination_location_id`) VALUES (15, 18, 10);
COMMIT;

-- ----------------------------
-- Table structure for ratings
-- ----------------------------
DROP TABLE IF EXISTS `ratings`;
CREATE TABLE `ratings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rating_count` int NOT NULL,
  `user_id` int NOT NULL,
  `review` text,
  `review_img` text,
  `destination_location_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ratings_user1_idx` (`user_id`),
  KEY `fk_ratings_destination_location1_idx` (`destination_location_id`),
  CONSTRAINT `fk_ratings_destination_location1` FOREIGN KEY (`destination_location_id`) REFERENCES `destination_location` (`id`),
  CONSTRAINT `fk_ratings_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of ratings
-- ----------------------------
BEGIN;
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (1, 4, 2, 'An iconic experience! The tour offers fascinating insights into the building\'s history, architecture, and cultural significance. The guides are knowledgeable, and the views of Sydney Harbour are stunning. A bit pricey, but absolutely worth it for the unique experience.', 'ratings/Hiranya9_18411098573.png', 9);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (2, 4, 2, 'A truly awe-inspiring experience! The Ruwanwelisaya stupa impresses with its massive scale and spiritual significance. Walking around the ancient structure, visitors can sense the history and sacred atmosphere, and the architectural marvel is a testament to the engineering skill of ancient Sri Lankans. The historical and religious insights provided make the visit enriching and deeply meaningful. A must-visit for those interested in history, culture, or spirituality.', 'ratings/Hiranya1_184423966323.png', 1);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (3, 5, 2, 'An unforgettable journey through art and history! The Vatican Museums offer an incredible collection, featuring masterpieces from ancient Roman sculptures to Renaissance art. Highlights include the awe-inspiring Sistine Chapel and Raphael\'s stunning frescoes. The vast array of artwork and cultural treasures makes the tour both educational and captivating. Though often crowded, the experience is truly one-of-a-kind and worth the visit for art lovers and history enthusiasts alike.', 'ratings/Hiranya6_184543394742.png', 6);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (4, 4, 2, 'A mesmerizing experience! Fushimi Inari Shrine enchants with its endless rows of vibrant red torii gates and serene forest trails. The hike up Mount Inari offers stunning views and a peaceful atmosphere, while the numerous fox statues add to the shrine\'s mystical charm. Rich in history and cultural significance, it’s a must-visit for anyone exploring Kyoto. Be prepared for some crowds, but the beauty and unique ambiance make it well worth it.', NULL, 3);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (5, 5, 2, 'The Vatican Museums tour offers an extraordinary experience, showcasing one of the world\'s most extensive and renowned art collections. As you navigate through the galleries, you\'ll encounter masterpieces from ancient Roman sculptures to iconic Renaissance works, including the breathtaking Sistine Chapel ceiling and Raphael\'s stunning frescoes in the Stanze di Raffaello. With over 20,000 artworks on display, the tour is a captivating journey through art history and the legacy of the Catholic Church. The sheer scale and beauty of the collections make it a must-visit for art enthusiasts and history buffs alike. The only drawback can be the large crowds, but the awe-inspiring art and architecture make it well worth the visit.', 'ratings/Hiranya6_103540120221.png', 6);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (6, 5, 2, 'Visiting the Pyramids of Giza is a mesmerizing experience. The Great Pyramid of Khufu stands as a testament to ancient engineering, while the smaller pyramids of Khafre and Menkaure showcase the grandeur of Egypt\'s pharaohs. The site\'s rich history and breathtaking desert backdrop make it a must-see destination. Knowledgeable guides enrich the experience with fascinating insights, ensuring you leave with a deep appreciation for these ancient wonders. Don’t miss the chance to explore this UNESCO World Heritage site—it\'s truly a journey through time!', 'ratings/Hiranya7_193353026039.png', 7);
INSERT INTO `ratings` (`id`, `rating_count`, `user_id`, `review`, `review_img`, `destination_location_id`) VALUES (7, 5, 2, 'Breathtaking Experience at the Great Wall of China!\" I recently took a guided tour of the Great Wall, and it was an unforgettable experience. The sheer scale and history of the Wall are awe-inspiring. Our guide was incredibly knowledgeable, providing fascinating insights into its construction and historical significance. The scenery was stunning, especially from the higher vantage points, where you can see the Wall stretch across the mountains as far as the eye can see.\r\nThe tour was well-organized, with ample time to explore different sections of the Wall at a comfortable pace. I would recommend wearing comfortable shoes, as there are some steep sections, but the effort is well worth it. This tour is a must-do for anyone visiting China—it\'s an incredible blend of history, culture, and natural beauty!\r\n', 'ratings/Hiranya14_19538554429.png', 14);
COMMIT;

-- ----------------------------
-- Table structure for reviews
-- ----------------------------
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `review` text NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_reviews_user1_idx` (`user_id`),
  CONSTRAINT `fk_reviews_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of reviews
-- ----------------------------
BEGIN;
INSERT INTO `reviews` (`id`, `review`, `user_id`) VALUES (2, 'I recently tried out a tour plan suggestion website powered by AI, and I must say, it exceeded my expectations. Here’s what I found: The website has an intuitive and clean interface, making it easy for both tech-savvy and less experienced users to navigate. The AI-driven suggestions are presented clearly, and the user flow from input to receiving results is smooth and straightforward. I appreciated the minimalistic design, which kept the focus on the essential features without overwhelming the user with too many options.    The AI-powered tour plan suggester is a game-changer for travelers, offering quick and personalized travel recommendations based on individual preferences like budget, interests, and travel dates. With its user-friendly interface and speed, it delivers tailored itineraries in seconds, including destination suggestions, hotel options, and day-by-day plans. The AI goes beyond mainstream attractions, recommending local experiences and hidden gems, making travel planning not only efficient but also more enriching. While there’s room to expand destination choices, the platform provides a seamless and insightful travel planning experience for all types of trips.\n\nUser-Friendly Interface\n\nThe website has an intuitive and clean interface, making it easy for both tech-savvy and less experienced users to navigate. The AI-driven suggestions are presented clearly, and the user flow from input to receiving results is smooth and straightforward. I appreciated the minimalistic design, which kept the focus on the essential features without overwhelming the user with too many options.\n\nPersonalized Recommendations\n\nOne of the standout features is its ability to tailor suggestions based on user preferences. After providing a few basic details like preferred travel dates, budget, interests (e.g., adventure, culture, relaxation), and even dietary preferences, the AI instantly generated a list of ideal destinations and activities. The suggestions felt genuinely personalized, as the AI incorporated nuanced details I hadn’t considered, like the best time to visit certain attractions or hidden gems at my destination.\n\nSpeed and Efficiency\n\nThe site excels at quickly processing input and delivering actionable recommendations. In less than a minute, I had a full-fledged tour plan that included transportation options, hotel suggestions, and even a day-by-day itinerary. This kind of speed and precision is a game-changer for travelers who want quick answers without spending hours researching online.', 3);
INSERT INTO `reviews` (`id`, `review`, `user_id`) VALUES (3, 'I recently used the travel itinerary generator, and I couldn\'t be happier with the experience! The user interface is intuitive and easy to navigate, making it simple to customize my travel plans. I loved the variety of destinations and activities available, which helped me create a personalized itinerary tailored to my interests.\n\nThe generator provided detailed information on attractions, travel times, and even suggested dining options, which saved me a lot of time in planning. I especially appreciated the option to share my itinerary with friends and family, making it easier for us to coordinate our trip.\n\nOverall, this tool is a must-try for anyone looking to plan their travels efficiently. Highly recommended!', 2);
INSERT INTO `reviews` (`id`, `review`, `user_id`) VALUES (5, 'The Travel AI itinerary page offers an impressive and user-friendly experience for planning trips. With its ability to personalize suggestions based on interests and preferences, it quickly generates a comprehensive itinerary that saves hours of research. The range of options for accommodations and activities is diverse, allowing for unique experiences tailored to individual tastes. However, some users might find customization a bit limited, and pricing for certain activities isn’t always transparent. Overall, it’s a fantastic tool for anyone looking to streamline their travel planning while maintaining a personalized touch.', 2);
COMMIT;

-- ----------------------------
-- Table structure for tour_type
-- ----------------------------
DROP TABLE IF EXISTS `tour_type`;
CREATE TABLE `tour_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of tour_type
-- ----------------------------
BEGIN;
INSERT INTO `tour_type` (`id`, `type`) VALUES (1, 'Adventure');
INSERT INTO `tour_type` (`id`, `type`) VALUES (2, 'Cultural');
INSERT INTO `tour_type` (`id`, `type`) VALUES (3, 'Ecotourism');
INSERT INTO `tour_type` (`id`, `type`) VALUES (4, 'Historical');
INSERT INTO `tour_type` (`id`, `type`) VALUES (5, 'Luxury');
INSERT INTO `tour_type` (`id`, `type`) VALUES (6, 'Nature and Wildlife');
INSERT INTO `tour_type` (`id`, `type`) VALUES (7, 'Religious');
INSERT INTO `tour_type` (`id`, `type`) VALUES (8, 'Road Trip');
INSERT INTO `tour_type` (`id`, `type`) VALUES (9, 'Romantic');
INSERT INTO `tour_type` (`id`, `type`) VALUES (10, 'Safari');
INSERT INTO `tour_type` (`id`, `type`) VALUES (11, 'Sightseeing');
INSERT INTO `tour_type` (`id`, `type`) VALUES (12, 'Sports');
INSERT INTO `tour_type` (`id`, `type`) VALUES (13, 'Wellness and Spa');
INSERT INTO `tour_type` (`id`, `type`) VALUES (14, 'Beach');
INSERT INTO `tour_type` (`id`, `type`) VALUES (15, 'Cruise');
INSERT INTO `tour_type` (`id`, `type`) VALUES (16, 'City Tour');
INSERT INTO `tour_type` (`id`, `type`) VALUES (17, 'Hiking');
INSERT INTO `tour_type` (`id`, `type`) VALUES (18, 'Food and Wine');
INSERT INTO `tour_type` (`id`, `type`) VALUES (19, 'Photography');
INSERT INTO `tour_type` (`id`, `type`) VALUES (20, 'Shopping');
INSERT INTO `tour_type` (`id`, `type`) VALUES (21, 'Entertainment');
COMMIT;

-- ----------------------------
-- Table structure for trip_plan
-- ----------------------------
DROP TABLE IF EXISTS `trip_plan`;
CREATE TABLE `trip_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plan_name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of trip_plan
-- ----------------------------
BEGIN;
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (1, 'test 5');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (2, 'plan 6');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (3, 'plan 7');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (4, 'plan 8');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (5, 'plan 9');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (6, 'plan 10');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (7, 'Test 5');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (8, 'Test 5');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (9, 'Test 15');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (10, 'my vacation trip 6');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (11, 'my vacation trip 6');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (12, 'my vacation trip 19');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (13, 'plan 30');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (14, 'Anuradhapura');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (15, 'Kandy');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (16, 'Testing 1');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (17, 'My Vacation');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (18, 'Summar Vcation');
INSERT INTO `trip_plan` (`id`, `plan_name`) VALUES (19, 'Summar Vacation Sri Lanka');
COMMIT;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of user
-- ----------------------------
BEGIN;
INSERT INTO `user` (`id`, `first_name`, `last_name`, `email`, `password`) VALUES (2, 'Hiranya', 'Semindi', 'hiranyasemindi@icloud.com', 'c48d831a0c0609ade8b22a2e153e6dfdb95e830c0393e5bfd66d2180c7d58fb82a58e9c70733490a425a0acb1685c10fdcbc52b97c4ea6a5133de2c74bfcebaa');
INSERT INTO `user` (`id`, `first_name`, `last_name`, `email`, `password`) VALUES (3, 'Virul', 'Nirmala', 'virulnirmala@icloud.com', 'd94c1345b6d4f1e9cb83162042e9bf99e853d86880030d484e5ba68fe29c635e7d6abaf10d5ff2dcab2082fe1d8391783617f1c172bd373213a8a5f7a52524f4');
COMMIT;

-- ----------------------------
-- Table structure for user_has_trip_plans
-- ----------------------------
DROP TABLE IF EXISTS `user_has_trip_plans`;
CREATE TABLE `user_has_trip_plans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trip_plan_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_trip_plan_has_user_user1_idx` (`user_id`),
  KEY `fk_trip_plan_has_user_trip_plan1_idx` (`trip_plan_id`),
  CONSTRAINT `fk_trip_plan_has_user_trip_plan1` FOREIGN KEY (`trip_plan_id`) REFERENCES `trip_plan` (`id`),
  CONSTRAINT `fk_trip_plan_has_user_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of user_has_trip_plans
-- ----------------------------
BEGIN;
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (1, 1, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (2, 2, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (3, 3, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (4, 4, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (5, 5, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (6, 6, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (7, 9, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (8, 10, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (9, 12, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (10, 13, 3);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (11, 14, 2);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (12, 15, 2);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (13, 16, 2);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (14, 17, 2);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (15, 18, 2);
INSERT INTO `user_has_trip_plans` (`id`, `trip_plan_id`, `user_id`) VALUES (16, 19, 2);
COMMIT;

-- ----------------------------
-- Table structure for wishlist
-- ----------------------------
DROP TABLE IF EXISTS `wishlist`;
CREATE TABLE `wishlist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `destination_location_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_wishlist_user1_idx` (`user_id`),
  KEY `fk_wishlist_destination_location1_idx` (`destination_location_id`),
  CONSTRAINT `fk_wishlist_destination_location1` FOREIGN KEY (`destination_location_id`) REFERENCES `destination_location` (`id`),
  CONSTRAINT `fk_wishlist_user1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of wishlist
-- ----------------------------
BEGIN;
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (1, 3, 1);
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (12, 2, 1);
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (14, 2, 6);
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (15, 2, 11);
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (16, 2, 14);
INSERT INTO `wishlist` (`id`, `user_id`, `destination_location_id`) VALUES (17, 2, 13);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
