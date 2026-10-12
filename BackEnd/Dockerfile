FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY BackEnd/Projet-CV.csproj BackEnd/
RUN dotnet restore BackEnd/Projet-CV.csproj

COPY BackEnd/ BackEnd/
RUN dotnet publish BackEnd/Projet-CV.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Projet-CV.dll"]
