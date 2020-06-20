ARG sdk_version=3.1

# Build
FROM mcr.microsoft.com/dotnet/core/sdk:${sdk_version}-alpine AS build

COPY . /app

# Install dependencies
RUN dotnet restore /app

# Test/Publish
RUN dotnet test /app \
 && dotnet publish /app -c Release -o /app/out

# Output
FROM mcr.microsoft.com/dotnet/core/aspnet:${sdk_version}-alpine

COPY --from=build /app/out .

ENTRYPOINT ["dotnet", "Api.dll"]
