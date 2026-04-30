import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailsPage extends StatefulWidget {
  final Map item;
  final bool isMovie; // Recebe da Home para saber se é Filme ou Série

  const DetailsPage({super.key, required this.item, required this.isMovie});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map _itemDetails = {};
  bool _isLoading = true;

  final String apiKey = '99dd1bc749f8d84486e3d5c276211ab5';

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    // Muda a rota da API baseado no tipo
    final type = widget.isMovie ? 'movie' : 'tv';
    final url = Uri.parse(
        'https://api.themoviedb.org/3/$type/${widget.item['id']}?api_key=$apiKey&language=pt-BR');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _itemDetails = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar detalhes: $e');
    }
  }

  // Se for filme mostra Horas/Minutos. Se for Série mostra quantidade de Temporadas.
  String _getDurationOrSeasons() {
    if (widget.isMovie) {
      final int? mins = _itemDetails['runtime'];
      if (mins == null || mins == 0) return '';
      return '${mins ~/ 60}h ${mins % 60}m';
    } else {
      final int? seasons = _itemDetails['number_of_seasons'];
      if (seasons == null) return '';
      return '$seasons Temporada${seasons > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _isLoading ? widget.item : _itemDetails;

    final posterPath = data['poster_path'];
    final backdropPath = data['backdrop_path'];

    final posterUrl = posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : 'https://via.placeholder.com/500x750?text=Sem+Imagem';

    final backdropUrl = backdropPath != null
        ? 'https://image.tmdb.org/t/p/w500$backdropPath'
        : posterUrl;

    final title = data['title'] ?? data['name'] ?? 'Sem título';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFBB2F)),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.network(
                  backdropUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF0A0A0A), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFFFBB2F), size: 24),
                      const SizedBox(width: 5),
                      Text(
                        data['vote_average']?.toStringAsFixed(1) ?? 'N/A',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFFFFBB2F),
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      if (!_isLoading &&
                          _getDurationOrSeasons().isNotEmpty) ...[
                        Icon(widget.isMovie ? Icons.access_time : Icons.tv,
                            color: Colors.grey, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          _getDurationOrSeasons(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (!_isLoading && data['genres'] != null)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['genres'] as List).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            border: Border.all(
                                color: const Color(0xFFFFBB2F), width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(genre['name'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  const Text('Sinopse',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    data['overview'] == null || data['overview'].isEmpty
                        ? 'Nenhuma sinopse disponível.'
                        : data['overview'],
                    style: const TextStyle(
                        fontSize: 16, color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Abrindo trailer no YouTube...')),
                        );
                      },
                      icon: const Icon(Icons.play_arrow,
                          color: Color(0xFF141414)),
                      label: const Text('ASSISTIR TRAILER',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141414),
                              fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFBB2F),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
