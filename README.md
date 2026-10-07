# Plateforme data Assurance - socle Azure et Snowflake

Infrastructure as Code (Terraform) du prototype.

- terraform/azure : landing zone Azure (stockage, Event Grid, Data Factory, Key Vault)
- terraform/snowflake : socle Snowflake (rôles, bases, entrepôts, intégrations)
- modules : modules Terraform réutilisables
- envs : variables par environnement (dev, qual, prod), sans aucun secret
- sql : scripts SQL versionnés
- docs : dossier d'exploitation

Règle : aucun déploiement manuel, tout passe par le pipeline CI/CD.
