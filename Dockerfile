# Étape 1 : Build (installe toutes les dépendances + build si besoin)
FROM node:18-alpine AS builder

WORKDIR /usr/src/app

# Copie d'abord les fichiers de dépendances → cache efficace
COPY package*.json ./

# Installe TOUTES les dépendances (dev incluses) pour le build
RUN npm ci

# Copie le reste du code source
COPY . .

# Si tu as un build (ex: TypeScript, React, etc.), lance-le ici
# RUN npm run build

# Étape 2 : Image finale ultra-légère (seulement prod)
FROM node:18-alpine

WORKDIR /usr/src/app

# Copie uniquement package.json + package-lock.json
COPY --from=builder /usr/src/app/package*.json ./

# Installe UNIQUEMENT les dépendances de production + nettoie le cache
RUN npm ci --omit=dev \
    && npm cache clean --force

# Copie les fichiers compilés ou le code source nécessaire
# Si tu as un dossier dist/build → COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app ./

# Optionnel : lance l'app en tant qu'utilisateur non-root pour plus de sécurité
USER node

EXPOSE 3000

CMD ["npm", "start"]
