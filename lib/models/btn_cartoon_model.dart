class BtnCartoonModel {
  final String url;
  final String image;

  const BtnCartoonModel({
    required this.url,
    required this.image,
  });

  static List<BtnCartoonModel> getListCartoonModels() {
    return const [
      BtnCartoonModel(
        url: 'https://www.youtube.com/@NickelodeonCyrillic',
        image: 'assets/images/nickelodion_logo.jpeg',
      ),
      BtnCartoonModel(
        url: 'https://www.boomerangtv.co.uk/videos',
        image: 'assets/images/boomerang_logo01.png',
      ),
      BtnCartoonModel(
        url: 'https://www.cartoonnetwork.co.uk/videos',
        image: 'assets/images/c_n_cartoon_image.png',
      ),
      BtnCartoonModel(
        url: 'https://www.youtube.com/watch?v=JgTbF05edtM',
        image: 'assets/images/fanny_cartoon_logo.png',
      ),
    ];
  }
}