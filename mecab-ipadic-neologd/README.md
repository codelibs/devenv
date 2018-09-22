# Neologd Build Environment for Docker

## Build Docker Image

```
docker build --rm -t codelibs/neologd-build .
```

## Run Docker Image

```
docker run -t --rm -v `readlink -f ../data/`:/data/ codelibs/neologd-build:latest
```

### Push Latest Image

```
docker push codelibs/neologd-build:latest
```

### Push Release Images

```
docker tag codelibs/neologd-build codelibs/neologd-build:1.0.0
docker push codelibs/neologd-build:1.0.0
```
