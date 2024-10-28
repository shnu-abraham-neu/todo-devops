#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
RUN apt-get update && apt-get install -y libgdiplus

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG VERSION
WORKDIR /src
COPY ["TodoApp/TodoApp.csproj", "TodoApp/"]
RUN dotnet restore "TodoApp/TodoApp.csproj"
COPY . .
WORKDIR "/src/TodoApp"
RUN dotnet build "TodoApp.csproj" -c Release -o /app/build -p:version=$VERSION

FROM build AS publish
ARG VERSION
RUN dotnet publish "TodoApp.csproj" -c Release -o /app/publish -p:version=$VERSION

FROM node:12.7-alpine as npmpublish
WORKDIR /src
COPY "TodoApp/ClientApp/" .
RUN npm install
RUN npm run publish

FROM base AS app
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=npmpublish /src/dist ClientApp/dist

FROM app as final
#Add new user
RUN addgroup --system --gid 1748 dotnet \
    && adduser --system --uid 1748 --ingroup dotnet --shell /bin/sh dotnet
# Add user permissions to the app directory
RUN chown -R dotnet:dotnet /app
# Select the user
USER 1748

ENTRYPOINT ["dotnet", "TodoApi.dll"]