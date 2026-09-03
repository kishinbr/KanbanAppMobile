<div align="center">

# 📱 Kanban App — Mobile

Aplicativo Android de um Kanban colaborativo, feito em **Flutter**, com autenticação por token e suporte a drag-and-drop.

`Flutter` · `Dart` · `JWT`

</div>

---

## Sobre o projeto

Um app de quadro Kanban para Android: crie quadros, organize colunas e cartões, convide outras pessoas com um código de compartilhamento, e arraste cartões entre colunas direto pelo celular.

## ✨ Funcionalidades

- Cadastro e login, com sessão salva localmente (não precisa logar toda vez)
- Painel com a lista dos seus kanbans, indicando se você é dono ou espectador
- Criar um novo kanban
- Entrar em um kanban de outra pessoa usando um código de compartilhamento
- Puxar a tela para baixo para atualizar (pull-to-refresh)
- Dentro de um quadro: colunas empilhadas verticalmente, e os cartões de cada uma em uma fileira horizontal
- Criar, editar e excluir colunas e cartões
- Mover cartões entre colunas com **drag-and-drop** (aperte e segure o cartão, arraste até a coluna desejada)
- Sair de um kanban (espectador) ou excluí-lo por completo (dono)
- Interface se adapta à sua permissão: espectadores só visualizam, sem botões de edição

## 🛠️ Stack

- **Flutter / Dart**
- `http` — comunicação com a API
- `shared_preferences` — sessão salva localmente no aparelho
- Material Design 3, tema escuro

## 🚀 Rodando o projeto

Pré-requisitos: [Flutter SDK](https://flutter.dev/) instalado, e um emulador Android ou aparelho físico.

```bash
git clone https://github.com/kishinbr/KanbanAppMobile.git
cd KanbanAppMobile
flutter pub get
flutter run
```

## 📦 Gerando um APK

```bash
flutter build apk --release
```

O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`, pronto para instalar em qualquer aparelho Android.

## 🗂️ Estrutura

```
lib/
├── models/     # Classes de dados (Usuario, Quadro, Coluna, Cartao...)
├── services/   # Comunicação com a API
└── screens/    # Telas do app (Login, Cadastro, Painel, Quadro)
```

## 📌 Próximos passos

- [ ] Entrar automaticamente se já houver uma sessão salva
- [ ] Reordenar cartões dentro da mesma coluna
- [ ] Melhor tratamento quando a sessão expira

---

<div align="center">
Feito como projeto de estudo em Flutter, consumindo uma API REST própria.
</div>
