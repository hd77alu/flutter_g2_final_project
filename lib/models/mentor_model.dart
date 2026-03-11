class Mentor {
  final String name;
  final String role;
  final double rating;

  Mentor({
    required this.name,
    required this.role,
    required this.rating,
  });

  factory Mentor.fromFirestore(Map<String, dynamic> data) {
    return Mentor(
      name: data['name'] ?? '',
      role: data['role'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}