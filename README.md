# autocare

# AutoCare

Aplicativo Flutter para gerenciamento de veículo, manutenção e custos.

## Configuração do Firebase

As dependências e o plugin Android já estão configurados. Para vincular o app a uma conta Firebase:

1. Crie ou selecione um projeto em [Firebase Console](https://console.firebase.google.com/).
2. Ative **Authentication > Sign-in method > E-mail/senha**.
3. No terminal, faça login:

	```powershell
	firebase login
	```

4. Na raiz do projeto, gere os arquivos de configuração:

	```powershell
	flutterfire configure
	```

	Selecione o projeto Firebase e o Android com o identificador `com.example.autocare`.

5. Valide a compilação:

	```powershell
	flutter pub get
	flutter build apk --debug
	```

O comando `flutterfire configure` gera o `google-services.json` em `android/app` e o arquivo de opções Dart necessários para a execução. Esses arquivos dependem do projeto Firebase escolhido e não podem ser gerados corretamente sem acesso à conta.
