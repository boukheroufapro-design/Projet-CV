# Projet-CV

Application composée d'un frontend Angular et d'une API ASP.NET Core.

## Structure

```text
Projet-CV/
├── BackEnd/                 # API ASP.NET Core et Dockerfile
├── FrontEnd/                # Application Angular, Nginx et Dockerfile
├── infra/azure/             # Infrastructure Azure en Bicep
├── .github/workflows/       # Construction et déploiement continus
└── docker-compose.yml       # Lancement local des deux conteneurs
```

## Lancer en local

Installe Docker Desktop, puis ouvre un terminal à la racine du dépôt :

```powershell
docker compose up --build
```

- Angular : <http://localhost:4200>
- API : <http://localhost:8080/weatherforecast>
- OpenAPI en développement : <http://localhost:8080/openapi/v1.json>

Nginx sert l'application Angular, redirige `/weatherforecast` et `/api/` vers l'API et renvoie les routes Angular vers `index.html`.

Pour arrêter les conteneurs, appuie sur `Ctrl+C`, puis lance `docker compose down`.

## Déploiement Azure

Le workflow GitHub Actions construit les images, les publie dans Azure Container Registry (ACR), puis déploie les deux Container Apps et leur environnement avec Bicep.

### Préparer Azure

1. Crée une inscription d'application (service principal) avec une fédération OpenID Connect pour GitHub Actions. Configure son rôle `Contributor` sur le groupe de ressources de déploiement. Le workflow se connecte à Azure sans mot de passe client.
2. Le workflow attribue `AcrPush` à son principal de service et le modèle Bicep attribue `AcrPull` aux identités des deux Container Apps. Pour créer ces assignations, le principal GitHub Actions doit recevoir le rôle `Role Based Access Control Administrator` (Administrateur du contrôle d'accès en fonction du rôle) sur l'ACR. L'ACR doit exister avant cette attribution : laisse un premier lancement le créer s'il n'existe pas, puis un administrateur Azure peut exécuter les commandes suivantes dans Azure Cloud Shell (Bash), en remplaçant les valeurs entre chevrons :

   ```bash
   az account set --subscription "<AZURE_SUBSCRIPTION_ID>"

   ACR_ID="$(az acr show \
     --name "<ACR_NAME>" \
     --resource-group "<AZURE_RESOURCE_GROUP>" \
     --query id \
     --output tsv)"
   PRINCIPAL_ID="$(az ad sp show \
     --id "<AZURE_CLIENT_ID>" \
     --query id \
     --output tsv)"

   az role assignment create \
     --assignee-object-id "$PRINCIPAL_ID" \
     --assignee-principal-type ServicePrincipal \
     --role "Role Based Access Control Administrator" \
     --scope "$ACR_ID"
   ```

   `AZURE_CLIENT_ID` est l'ID client de l'inscription d'application; `PRINCIPAL_ID` est son ID d'objet de principal de service (la propriété CLI est `id`, pas `objectId`). Configure `PRINCIPAL_ID` comme variable GitHub Actions `AZURE_PRINCIPAL_ID`, puis relance le workflow. Attribuer seulement `AcrPush` ne suffit pas : Bicep doit aussi créer les deux assignations `AcrPull`. Si le premier lancement ne peut pas enregistrer les fournisseurs `Microsoft.ContainerRegistry` et `Microsoft.App`, demande à un administrateur Azure de les enregistrer dans l'abonnement.
3. Configure les variables GitHub Actions du dépôt :
   - `AZURE_RESOURCE_GROUP`
   - `AZURE_LOCATION` (par exemple `westeurope`)
   - `ACR_NAME` (nom globalement unique, de 5 à 50 caractères, minuscules et chiffres uniquement)
   - `AZURE_ENVIRONMENT_NAME`
   - `AZURE_API_APP_NAME`
   - `AZURE_FRONTEND_APP_NAME`
   - `AZURE_PRINCIPAL_ID` (ID d'objet du service principal GitHub Actions dans Azure)
4. Configure les secrets GitHub Actions :
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
5. Dans `infra/azure/parameters.json`, remplace les noms d'exemple et vérifie la région. Les valeurs d'images sont fournies par le workflow lors du déploiement.
6. Ajoute la fédération OIDC GitHub Actions à l'inscription d'application, puis pousse sur `master` ou `main` (selon la branche utilisée par le dépôt), ou lance manuellement le workflow **Build and deploy to Azure**.

Le workflow crée le groupe de ressources et l'ACR s'ils n'existent pas, construit et pousse les images, puis déploie `infra/azure/main.bicep`. Le frontend est exposé publiquement ; l'API reste accessible uniquement depuis l'environnement Container Apps. Son URL est transmise à Nginx lors du démarrage.

Le workflow valide les variables et secrets requis avant de se connecter à Azure, puis vérifie l'abonnement et enregistre les fournisseurs Azure nécessaires. Il réutilise un groupe de ressources et un registre ACR existants. Pour un groupe de ressources existant, `AZURE_LOCATION` reste la région des ressources déployées ; changer la région du groupe existant n'est pas possible par cette variable.

N'ajoute aucun secret, fichier `.env` ou identifiant Azure au dépôt.
