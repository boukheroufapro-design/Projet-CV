# Projet-CV

Application composée d'un frontend Angular et d'une API ASP.NET Core.

## Structure

```text
Projet-CV/
├── BackEnd/                 # API ASP.NET Core et Dockerfile
├── FrontEnd/                # Application Angular, Nginx et Dockerfile
└── docker-compose.yml       # Lancement local des deux conteneurs
```

## Lancer en local

Installe Docker Desktop, puis ouvre un terminal à la racine du dépôt :

```powershell
docker compose up --build
```

- Angular : <http://localhost:4200>
- API : <http://localhost:8080/MoneyManager>
- OpenAPI en développement : <http://localhost:8080/openapi/v1.json>

Nginx sert l'application Angular, redirige `/MoneyManager` et `/api/` vers l'API et renvoie les routes Angular vers `index.html`.

Pour arrêter les conteneurs, appuie sur `Ctrl+C`, puis lance `docker compose down`.
