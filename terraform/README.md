```
aws sso login
docker compose run -v "$(readlink -f ..)/$PROJECT:/project" main
cd /project
terraform apply
```

Configuration
-------------

Configure AWS account with `aws configure sso`. The config folder (`/home/worker/.aws`) is bind mounted from `mnt/aws-config` so logins persist between containers.
