class CategoriesModel {
  CategoriesModel({
    required this.kategori,
    required this.subKategori,
  });

  List<String> kategori;
  List<String> subKategori;

  factory CategoriesModel.fromJson(Map<String, dynamic> json) => CategoriesModel(
        kategori: json["kategori"],
        subKategori: json["subKategori"],
      );

  Map<String, dynamic> toJson() => {
        "kategori": kategori,
        "subKategori": subKategori,
      };
}
