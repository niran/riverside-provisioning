```
docker compose run -v "$(readlink -f ..)/$PROJECT:/project" main
```

Configuration
-------------

Log in to AWS with `aws configure sso`. The config folder (`/home/worker/.aws`) is bind mounted from `mnt/aws-config` so logins persist between containers.
