import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_restaurant/models/dish.dart';
import 'package:digital_restaurant/models/review.dart';
import 'package:digital_restaurant/services/favorites_services.dart';
import 'package:digital_restaurant/services/review_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final Dish dish;
  const DetailPage({super.key, required this.dish});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  int quantity = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isButtonPressed = false;
  bool _isFavorite = false;
  bool _isCheckingFavorite = true;
  
  late TabController _tabController;
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 5.0;
  bool _hasUserReviewed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkFavoriteStatus();
    _checkUserReviewStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final result = await FavoritesService.isInFavorites(widget.dish.id!);
    if (mounted) {
      setState(() {
        _isFavorite = result;
        _isCheckingFavorite = false;
      });
    }
  }

  Future<void> _checkUserReviewStatus() async {
    final hasReviewed = await ReviewService.hasUserReviewed(widget.dish.id!);
    if (mounted) {
      setState(() => _hasUserReviewed = hasReviewed);
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await FavoritesService.toggleFavorite(context, widget.dish.id!);
    if (mounted) {
      setState(() => _isFavorite = newStatus);
    }
  }

  Future<void> _addToCart() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add to cart')),
      );
      return;
    }

    try {
      await _firestore
          .collection('carts')
          .doc(user.uid)
          .collection('items')
          .doc(widget.dish.id)
          .set({
        'dishId': widget.dish.id,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${quantity}x ${widget.dish.title} added')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final success = await ReviewService.addReview(
      dishId: widget.dish.id!,
      rating: _selectedRating,
      comment: _reviewController.text.trim(),
      context: context,
    );

    if (success) {
      _reviewController.clear();
      setState(() {
        _selectedRating = 5.0;
        _hasUserReviewed = true;
      });
    }
  }

  Widget _buildStarRating(double rating, {bool interactive = false, double size = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: interactive ? () {
            setState(() => _selectedRating = index + 1.0);
          } : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.dish.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "\$${widget.dish.price.toString()}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating
          if (widget.dish.reviewCount > 0) ...[
            Row(
              children: [
                _buildStarRating(widget.dish.averageRating),
                const SizedBox(width: 8),
                Text(
                  '${widget.dish.averageRating.toStringAsFixed(1)} (${widget.dish.reviewCount} reviews)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Description
          Text(
            widget.dish.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300
            ),
          ),

          const SizedBox(height: 40),

          
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return StreamBuilder<List<Review>>(
      stream: ReviewService.getReviewsStream(widget.dish.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Column(
            children: [
              if (!_hasUserReviewed && _auth.currentUser != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Write a Review',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Rating: '),
                          _buildStarRating(_selectedRating, interactive: true, size: 24),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reviewController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _submitReview,
                        child: const Text('Submit Review'),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Reviews List
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final isCurrentUser = _auth.currentUser?.uid == review.userId;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      review.userName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildStarRating(review.rating),
                                  if (isCurrentUser)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () async {
                                        if (!mounted) return;
                                        final success = await ReviewService.deleteReview(
                                          review.id!,
                                          widget.dish.id!,
                                          context,
                                        );
                                        if (success && mounted) {
                                          setState(() => _hasUserReviewed = false);
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(review.comment),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Image with favorite button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.dish.imagePath,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 12,
                  right: 12,
                  child: _isCheckingFavorite
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : InkWell(
                          onTap: _toggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 24,
                              color: _isFavorite ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar
          TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildReviewsTab(),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.remove, 
                            size: 20, 
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      SizedBox(
                        width: 40,
                        child: Text(
                          quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      InkWell(
                        onTap: () => setState(() => quantity++),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Icon(
                            Icons.add, 
                            size: 20, 
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Add to cart button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isButtonPressed = true);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        _addToCart();
                        setState(() => _isButtonPressed = false);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _isButtonPressed 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                          : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: _isButtonPressed ? 14 : 16,
                        horizontal: _isButtonPressed ? 10 : 0,
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: _isButtonPressed ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          child: const Text('Add to cart'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}