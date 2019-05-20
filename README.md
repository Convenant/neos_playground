# neos

To build:

```bash
docker build . -t php:7.1.29-neos
```

To run:

```bash
docker-compose up
```

Jump into the container:
```bash
docker exec -it $(docker ps -a | grep "php:7.1.29-neos" | awk '{print $1}') /bin/bash
```
