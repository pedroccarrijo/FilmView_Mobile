import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _items = [];
  bool _isLoading = true;
  bool _isShowingMovies = true;

  String _searchQuery = '';
  int _currentPage = 1;
  int? _selectedGenreId;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String apiKey = '99dd1bc749f8d84486e3d5c276211ab5';

  final List<Map<String, dynamic>> _movieGenres = [
    {'id': 28, 'name': 'Ação'},
    {'id': 35, 'name': 'Comédia'},
    {'id': 18, 'name': 'Drama'},
    {'id': 27, 'name': 'Terror'},
    {'id': 878, 'name': 'Ficção'},
  ];

  final List<Map<String, dynamic>> _tvGenres = [
    {'id': 10759, 'name': 'Ação'},
    {'id': 35, 'name': 'Comédia'},
    {'id': 18, 'name': 'Drama'},
    {'id': 16, 'name': 'Animação'},
    {'id': 10765, 'name': 'Ficção'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    String urlString;
    final type = _isShowingMovies ? 'movie' : 'tv';

    if (_searchQuery.isNotEmpty) {
      urlString =
          'https://api.themoviedb.org/3/search/$type?api_key=$apiKey&language=pt-BR&query=$_searchQuery&page=$_currentPage';
    } else if (_selectedGenreId != null) {
      urlString =
          'https://api.themoviedb.org/3/discover/$type?api_key=$apiKey&language=pt-BR&with_genres=$_selectedGenreId&page=$_currentPage';
    } else {
      urlString =
          'https://api.themoviedb.org/3/$type/popular?api_key=$apiKey&language=pt-BR&page=$_currentPage';
    }

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _items = data['results'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro de conexão: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(Map item, bool isCurrentlyFavorite) async {
    if (currentUser == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('favorites')
        .doc(item['id'].toString());

    try {
      if (isCurrentlyFavorite) {
        await docRef.delete();
      } else {
        await docRef.set({
          'id': item['id'],
          'title': item['title'] ?? item['name'],
          'poster_path': item['poster_path'],
          'vote_average': item['vote_average'],
          'overview': item['overview'],
          'is_movie': _isShowingMovies,
          'saved_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("Erro ao salvar: $e");
    }
  }

  void _changePage(int newPage) {
    if (newPage < 1) return;
    setState(() {
      _currentPage = newPage;
    });
    _fetchData();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGenres = _isShowingMovies ? _movieGenres : _tvGenres;

    int startPage = _currentPage > 2 ? _currentPage - 2 : 1;
    List<int> visiblePages = List.generate(5, (index) => startPage + index);

    String dynamicTitle = '';
    if (_searchQuery.isNotEmpty) {
      dynamicTitle = 'Resultados para: "$_searchQuery"';
    } else if (_selectedGenreId != null) {
      final genreName = currentGenres.firstWhere(
          (g) => g['id'] == _selectedGenreId,
          orElse: () => {'name': ''})['name'];
      dynamicTitle = genreName;
    } else {
      dynamicTitle = _isShowingMovies
          ? 'Últimos filmes adicionados'
          : 'Últimas séries adicionadas';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmView Explorar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFFBB2F)),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARRA DE BUSCA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value;
                  _selectedGenreId = null;
                  _currentPage = 1;
                });
                _fetchData();
              },
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFBB2F)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _currentPage = 1;
                          });
                          _fetchData();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // BOTÕES FILMES / SÉRIES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isShowingMovies
                          ? const Color(0xFFFFBB2F)
                          : const Color(0xFF1A1A1A),
                      foregroundColor: _isShowingMovies
                          ? const Color(0xFF141414)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (!_isShowingMovies) {
                        setState(() {
                          _isShowingMovies = true;
                          _searchQuery = '';
                          _selectedGenreId = null;
                          _currentPage = 1;
                        });
                        _fetchData();
                      }
                    },
                    child: const Text('Filmes',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isShowingMovies
                          ? const Color(0xFFFFBB2F)
                          : const Color(0xFF1A1A1A),
                      foregroundColor: !_isShowingMovies
                          ? const Color(0xFF141414)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_isShowingMovies) {
                        setState(() {
                          _isShowingMovies = false;
                          _searchQuery = '';
                          _selectedGenreId = null;
                          _currentPage = 1;
                        });
                        _fetchData();
                      }
                    },
                    child: const Text('Séries',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // FILTRO DE GÊNEROS
          if (_searchQuery.isEmpty)
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: currentGenres.length,
                itemBuilder: (context, index) {
                  final genre = currentGenres[index];
                  final isSelected = _selectedGenreId == genre['id'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(genre['name']),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFFBB2F),
                      backgroundColor: const Color(0xFF1A1A1A),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? const Color(0xFF141414) : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      showCheckmark: false,
                      onSelected: (selected) {
                        setState(() {
                          _selectedGenreId = selected ? genre['id'] : null;
                          _currentPage = 1;
                        });
                        _fetchData();
                      },
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          // TÍTULO DINÂMICO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              dynamicTitle,
              style: const TextStyle(
                  color: Colors
                      .white, 
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          // LISTA DE RESULTADOS
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFBB2F)))
                : _items.isEmpty
                    ? const Center(
                        child: Text("Nenhum resultado encontrado.",
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final posterPath = item['poster_path'];
                          final imageUrl = posterPath != null
                              ? 'https://image.tmdb.org/t/p/w500$posterPath'
                              : 'https://via.placeholder.com/500x750?text=Sem+Imagem';
                          final title =
                              item['title'] ?? item['name'] ?? 'Sem título';

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
                                        item: item, isMovie: _isShowingMovies),
                                  ),
                                );
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Image.network(imageUrl,
                                        width: 110, fit: BoxFit.cover),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
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
                                                    color: Color(0xFFFFBB2F),
                                                    size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item['vote_average']
                                                          ?.toStringAsFixed(
                                                              1) ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                      color: Color(0xFFFFBB2F),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item['overview'] ??
                                                  'Sem sinopse.',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (currentUser != null)
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: StreamBuilder<
                                                    DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(currentUser!.uid)
                                                      .collection('favorites')
                                                      .doc(
                                                          item['id'].toString())
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    bool isFavorite = snapshot
                                                            .hasData &&
                                                        snapshot.data!.exists;
                                                    return IconButton(
                                                      icon: Icon(
                                                        isFavorite
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color: isFavorite
                                                            ? Colors.redAccent
                                                            : Colors.grey,
                                                        size: 28,
                                                      ),
                                                      onPressed: () =>
                                                          _toggleFavorite(
                                                              item, isFavorite),
                                                    );
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
                      ),
          ),

          // GUIAS DE PAGINAÇÃO
          if (!_isLoading && _items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF0A0A0A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Color(0xFFFFBB2F)),
                    onPressed: _currentPage > 1
                        ? () => _changePage(_currentPage - 1)
                        : null,
                  ),
                  ...visiblePages.map((pageNumber) {
                    bool isCurrent = pageNumber == _currentPage;
                    return GestureDetector(
                      onTap: () => _changePage(pageNumber),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFFFBB2F)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: isCurrent
                                ? const Color(0xFF141414)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: Color(0xFFFFBB2F)),
                    onPressed: () => _changePage(_currentPage + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
