# Projet-CV

Application composée d'un frontend Angular et d'une API ASP.NET Core.

## Structure

```text
Projet-CV/
├── BackEnd/                 # API ASP.NET Core
└── FrontEnd/                # Application Angular
```

## Lancer en local

Lance l'API et le frontend dans deux terminaux distincts.

Dans un terminal :

```shell
cd BackEnd
dotnet run
```

Dans un autre terminal :

```shell
cd FrontEnd
npm install
npm start
```

- Angular : <http://localhost:4200>
- API : <http://localhost:5119/MoneyManager>
- OpenAPI en développement : <http://localhost:5119/openapi/v1.json>
