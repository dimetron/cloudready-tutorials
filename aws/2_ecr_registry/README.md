# AWS ECR Tutorial

In this tutorial we create 3 ECR registries using terraform

1. Top level used as docekr login
2. 2 Child registries will have actual images

```bash
   ecr_repository
   ecr_repository/devops-cli
   ecr_repository/base-image
``` 