# 🎬 FilmView Mobile (Flutter)

Um aplicativo nativo de catálogo de filmes e séries desenvolvido em **Flutter**, consumindo a API REST do TMDB e integrado ao **Google Firebase** para Autenticação e Banco de Dados em tempo real.

## 🚀 Funcionalidades

- **Autenticação Segura:** Sistema de Login e Cadastro de usuários utilizando **Firebase Authentication**, com persistência inteligente de sessão (login automático).
- **Consumo de API Externa:** Listagem de filmes e séries populares consumindo dados em tempo real do **TMDB API** via pacote `http`.
- **Busca, Filtros e Paginação:** Pesquisa inteligente por texto, filtros dinâmicos por Gêneros (Ação, Comédia, Drama, Terror, etc.) e paginação interativa para explorar o catálogo completo.
- **Lista de Favoritos:** Integração com **Cloud Firestore (NoSQL)**. Os usuários podem favoritar títulos, salvando-os instantaneamente na nuvem, com os dados atrelados ao seu ID único (UID) e visualizados em uma guia dedicada.
- **Detalhes Completos:** Tela de informações aprofundadas com banners, notas, sinopse, categorias e suporte dinâmico para duração (filmes) ou quantidade de temporadas (séries).
- **Design System Consistente:** Interface em "Dark Mode" com detalhes em `#FFBB2F`, garantindo conforto visual e usabilidade premium.

## 🌐 Teste o App
(Baixar APK):** O arquivo instalável `app-release.apk` está disponível na raiz deste repositório para instalação em dispositivos Android.

## 🛠️ Tecnologias Utilizadas

- **[Flutter & Dart](https://flutter.dev/)** - Framework mobile UI.
- **[Firebase Auth](https://firebase.google.com/docs/auth)** - Gerenciamento de usuários.
- **[Cloud Firestore](https://firebase.google.com/docs/firestore)** - Banco de dados NoSQL.
- **[HTTP](https://pub.dev/packages/http)** - Cliente para requisições de rede.
- **TMDB API** - Fonte dos dados de cinema e televisão.

## 💻 Como rodar o projeto localmente

Siga os comandos abaixo no seu terminal para configurar o ambiente:
```bash
# 1. Clone o repositório
git clone [https://github.com/pedroccarrijo/filmview_mobile.git](https://github.com/pedroccarrijo/filmview_mobile.git)

# 2. Entre na pasta do projeto
cd filmview_mobile

# 3. Obtenha as dependências
flutter pub get

# 4. Inicie o aplicativo (certifique-se de ter um emulador ou dispositivo conectado)
flutter run


Arquitetura 
Usuário (Celular / Navegador)
   │
   ├──> Camada de Apresentação (Flutter Widgets)
   │      ├──> LoginPage (UI de Autenticação)
   │      ├──> MainScreen (Navegação Inferior / Controle de Abas)
   │      ├──> HomePage (Lista, Filtros, Busca e Paginação)
   │      ├──> FavoritesPage (Stream do banco em tempo real)
   │      └──> DetailsPage (Página de Informações do Filme/Série)
   │
   ├──> Camada Lógica / Controle de Estado (Stateful Widgets)
   │      ├──> Validação de formulários e Sessão
   │      └──> Gerenciamento do _isLoading, Rotas da API e Listas
   │
   └──> Camada de Dados (Serviços Externos)
          ├──> Firebase Auth (Criação de Contas / Validação)
          ├──> TMDB API (GET Filmes, Séries, Buscas e Gêneros via pacote http)
          └──> Cloud Firestore (Salvar/Remover filmes favoritos por UID)
