import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'details_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
          child: Text('Usuário não logado.',
              style: TextStyle(color: Colors.white)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFFBB2F)),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      // O StreamBuilder atualiza a tela instantaneamente se o banco mudar
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('favorites')
            .orderBy('saved_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFBB2F)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não curtiu nenhum título.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final favorites = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index].data() as Map<String, dynamic>;
              final posterPath = item['poster_path'];
              final imageUrl = posterPath != null
                  ? 'https://image.tmdb.org/t/p/w500$posterPath'
                  : 'https://via.placeholder.com/500x750?text=Sem+Imagem';

              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          item: item,
                          isMovie: item['is_movie'] ??
                              true, // Garante que abra o detalhe certo
                        ),
                      ),
                    );
                  },
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.network(imageUrl, width: 110, fit: BoxFit.cover),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? 'Sem título',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Color(0xFFFFBB2F), size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['vote_average']
                                              ?.toStringAsFixed(1) ??
                                          'N/A',
                                      style: const TextStyle(
                                          color: Color(0xFFFFBB2F),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['overview'] ?? 'Sem sinopse.',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.redAccent, size: 28),
                                    onPressed: () async {
                                      // Remove dos favoritos ao clicar
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(currentUser.uid)
                                          .collection('favorites')
                                          .doc(item['id'].toString())
                                          .delete();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
