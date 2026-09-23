# TRACE

> **Record your journey.**

TRACE é um aplicativo mobile desenvolvido em **Flutter** para o registro de experiências e observações durante viagens, trilhas, acampamentos e outras atividades de campo.

O projeto explora a integração do Flutter com **recursos nativos do dispositivo**, utilizando reconhecimento de voz e controle da lanterna para tornar o registro de informações mais prático em diferentes situações.

## Funcionalidades

- Criação de anotações
- Edição e exclusão de anotações
- Reconhecimento de voz para preenchimento dos campos
- Controle da lanterna diretamente pelo aplicativo
- Interface responsiva e minimalista

## Recursos nativos

### Reconhecimento de voz

Utiliza o package [`speech_to_text`](https://pub.dev/packages/speech_to_text) para acessar o reconhecimento de voz do dispositivo e transformar a fala do usuário em texto.

O recurso pode ser utilizado tanto no título quanto no conteúdo das anotações.

### Lanterna

Utiliza o package [`torch_light`](https://pub.dev/packages/torch_light) para verificar a disponibilidade da lanterna e controlar o flash do dispositivo.

## Tecnologias

- Flutter
- Dart
- speech_to_text
- torch_light
- Material Design

## Estrutura

O projeto mantém uma estrutura simples, separando a interface principal, o formulário de anotações e o modelo utilizado pela aplicação.

```text
lib/
├── main.dart
├── tela_inicial.dart
├── nova_anotacao.dart
└── anotacao.dart
```

## Executando o projeto

Clone o repositório:

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta:

```bash
cd trace-app
```

Instale as dependências:

```bash
flutter pub get
```

Execute:

```bash
flutter run
```

> Para testar todos os recursos nativos, recomenda-se utilizar um dispositivo Android físico.

## Sobre o projeto

O TRACE foi desenvolvido como projeto acadêmico da disciplina de **Mobile III**, do curso de **Análise e Desenvolvimento de Sistemas**.

O objetivo do projeto é demonstrar, de forma prática, a utilização de plugins Flutter para integração com recursos nativos de dispositivos móveis.

---

**TRACE** · *Record your journey.*