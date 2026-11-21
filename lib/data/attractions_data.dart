class Attraction {
  final String title;
  final String location;
  final String description;
  final String image;
  final String category;
  final String wikiKey;

  Attraction({
    required this.title,
    required this.location,
    required this.description,
    required this.image,
    this.category = "Historical",
    required this.wikiKey,
  });
}

List<Attraction> attractions = [
  Attraction(
    title: "Pyramids of Giza",
    location: "Giza, Egypt",
    description:
        "One of the Seven Wonders of the Ancient World. Built as monumental tombs for Ancient Egyptian Pharaohs.",
    image: "assets/images/pyramids.jpg",
    category: "Historical",
    wikiKey: "Pyramids_of_Giza",
  ),
  Attraction(
    title: "Luxor Temple",
    location: "Luxor, Egypt",
    description:
        "A large ancient Egyptian temple complex located on the east bank of the Nile River.",
    image: "assets/images/luxor.jpg",
    category: "Historical",
    wikiKey: "Luxor_Temple",
  ),
  Attraction(
    title: "Abu Simbel",
    location: "Aswan, Egypt",
    description:
        "Two massive rock-cut temples carved out of the mountainside during the reign of Pharaoh Ramesses II.",
    image: "assets/images/abusimbel.jpg",
    category: "Historical",
    wikiKey: "Abu_Simbel",
  ),
  Attraction(
    title: "Cairo Tower",
    location: "Cairo, Egypt",
    description:
        "A free-standing concrete tower in Cairo, providing 360-degree panoramic views of the city.",
    image: "assets/images/cairotower.jpg",
    category: "Towers",
    wikiKey: "Cairo_Tower",
  ),
  Attraction(
    title: "Bibliotheca Alexandrina",
    location: "Alexandria, Egypt",
    description:
        "A major library and cultural center located on the shore of the Mediterranean Sea.",
    image: "assets/images/library.jpg",
    category: "Museums",
    wikiKey: "Bibliotheca_Alexandrina",
  ),
  Attraction(
    title: "Egyptian Museum",
    location: "Cairo, Egypt",
    description:
        "Home to an extensive collection of ancient Egyptian antiquities.",
    image: "assets/images/mthf.jpg",
    category: "Museums",
    wikiKey: "Egyptian_Museum",
  ),
  Attraction(
    title: "Karnak Temple",
    location: "Luxor, Egypt",
    description:
        "Vast mix of decayed temples, chapels, pylons, and other buildings near Luxor.",
    image: "assets/images/luxor.jpg",
    category: "Historical",
    wikiKey: "Karnak",
  ),
  Attraction(
    title: "Valley of the Kings",
    location: "Luxor, Egypt",
    description:
        "A valley in Egypt where, for a period of nearly 500 years, tombs were excavated for the pharaohs.",
    image: "assets/images/pyramids.jpg",
    category: "Historical",
    wikiKey: "Valley_of_the_Kings",
  ),
  Attraction(
    title: "Cairo Citadel",
    location: "Cairo, Egypt",
    description:
        "A medieval Islamic-era fortification in Cairo built by Salah ad-Din.",
    image: "assets/images/cairotower.jpg",
    category: "Historical",
    wikiKey: "Cairo_Citadel",
  ),
  Attraction(
    title: "Philae Temple",
    location: "Aswan, Egypt",
    description:
        "An island with a temple complex in Lake Nasser, famous for its association with Isis.",
    image: "assets/images/abusimbel.jpg",
    category: "Historical",
    wikiKey: "Philae",
  ),
];
