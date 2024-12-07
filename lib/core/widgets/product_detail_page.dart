import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yesil_piyasa/model/product.dart';
import 'package:yesil_piyasa/viewmodel/user_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorited();
  }

  // Beğeni durumu kontrolü
  Future<void> isFavorited() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    bool favorited = await userModel.isFavorited(
        widget.product.productID, userModel.user!.userID);
    setState(() {
      isFavorite = favorited;
    });
  }

  // Beğeni ekleme veya kaldırma işlemi
  Future<void> toggleFavorite(String productId) async {
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (isFavorite) {
      await userModel.removeProductFromFavorites(productId);
      await userModel.removeLikeFromProduct(productId);
      setState(() {
        isFavorite = false;
      });
    } else {
      await userModel.addProductToFavorites(productId);
      await userModel.addLikeToProduct(productId);
      setState(() {
        isFavorite = true;
      });
    }
  }

  // Kategori ismini dönme
  String getCategoryNames(String category) {
    switch (category.toLowerCase()) {
      case '0':
        return 'Meyve';
      case '1':
        return 'Sebze';
      case '2':
        return 'Tahıl';
      default:
        return 'Diğer';
    }
  }

  // Kategoriye ait görseli döndürme
  String getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case '0':
        return 'assets/images/meyve.jpg';
      case '1':
        return 'assets/images/sebze.jpg';
      case '2':
        return 'assets/images/tahil.jpg';
      default:
        return 'assets/images/diger.jpg';
    }
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'İletişim Bilgileri',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  onTap: () => _launchPhoneNumber(
                      'tel:+901234567890'), // Telefon numarasına tıklanırsa arama yapar
                  child: const Text(
                    'Telefon: +90 123 456 7890',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'E-posta: example@example.com',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Kapat',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchPhoneNumber(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Telefon numarası açılamadı: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ürün görseli
            Stack(
              children: [
                widget.product.imageUrl != null
                    ? Image.network(
                        widget.product.imageUrl!,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        getCategoryImage(widget.product.category),
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Detay bilgileri
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green, Colors.blue]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.product.price.toStringAsFixed(2)} ₺ / ${widget.product.unit}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.product.description ?? "Açıklama mevcut değil.",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Stok",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "${widget.product.stock}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Kategori",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    getCategoryNames(widget.product.category),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    'Birim Fiyatı',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '${widget.product.price} ₺ / ${widget.product.unit}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    'Satış Tarihi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '${widget.product.createdAt}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          // Firestore'dan dinlenebilir ve UI anında güncellenebilir
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .doc(widget.product.productID)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Text(
                                  "Beğeniler: 0",
                                  style: TextStyle(color: Colors.white70),
                                );
                              }
                              final productData = snapshot.data!;
                              final likes = productData['likes'] ?? 0;
                              return Text(
                                "Beğeniler: $likes",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 20),
                              );
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.phoneAlt, // Telefon ikonu
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _showContactDialog(context); // Dialog aç
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60.0, // Buton genişliği
        height: 60.0, // Buton yüksekliği
        decoration: BoxDecoration(
          color: Colors.white, // Buton arka planı beyaz
          shape: BoxShape.circle, // Yuvarlak şekil
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.black, // İkon rengi
          ),
          onPressed: () {
            toggleFavorite(widget.product.productID);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
