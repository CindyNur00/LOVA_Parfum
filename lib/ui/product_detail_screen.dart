import 'package:flutter/material.dart';
import 'package:tubes_parfum/model/product_model.dart';
import 'package:tubes_parfum/widgets/rating_stars.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tubes_parfum/ui/parfum_cart.dart';

import 'package:tubes_parfum/widgets/cart_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductDetail product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;

  double get totalPrice {
    return widget.product.price * quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4CDDD), // Background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              Share.share(
                'Check out this perfume: ${widget.product.name} - Rp${widget.product.price.toStringAsFixed(0)}!'
                    '${widget.product.fragranceDescription ?? ''}\n'
                    'Check Parfum ${widget.product.name}',
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? const Color(0xFF781D26) : Colors.black, // Primary dark for favorite
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCA99AB), // Lighter background for image container
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: widget.product.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.product.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
                  ),
                )
                    : const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? const Color(0xFF781D26) : Colors.grey, // Primary dark for favorite
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                    ],
                  ),

                  // Rating
                  RatingStars(rating: widget.product.rating, size: 24),
                  const SizedBox(height: 16),

                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.product.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 16),

                  if (widget.product.ingredients != null) ...[
                    const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.product.ingredients!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                  ],

                  if (widget.product.topNotes != null)
                    _buildNoteRow('Top Notes:', widget.product.topNotes!),
                  if (widget.product.heartNotes != null)
                    _buildNoteRow('Heart Notes:', widget.product.heartNotes!),
                  if (widget.product.baseNotes != null)
                    _buildNoteRow('Base Notes:', widget.product.baseNotes!),

                  if (widget.product.fragranceDescription != null) ...[
                    const SizedBox(height: 16),
                    Text(widget.product.fragranceDescription!, style: const TextStyle(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 24),
                  ],

                  // Price & Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4C1208)), // Darkest for price
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('$quantity', style: const TextStyle(fontSize: 18)),
                          ),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF893A49), // Accent color for button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Add To Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteRow(String label, String notes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(notes, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _addToCart() {
    final productToAdd = widget.product;
    final quantityToAdd = quantity;

    // Gunakan CartManager untuk menambah/memperbarui item
    CartManager().addOrUpdateProduct(productToAdd, quantityToAdd);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.name} (x$quantity) to cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4C1208),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParfumCart(), // Tidak perlu initialItems lagi
      ),
    );
  }
}