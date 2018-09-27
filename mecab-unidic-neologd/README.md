# Neologd Build Environment for Docker

## Build Docker Image

```
docker build --rm -t codelibs/unidic-neologd-build .
```

## Run Docker Image

```
docker run -t --rm -v `readlink -f ../data/`:/data/ codelibs/unidic-neologd-build:latest
```

### Push Latest Image

```
docker push codelibs/unidic-neologd-build:latest
```

### Push Release Images

```
docker tag codelibs/unidic-neologd-build codelibs/unidic-neologd-build:1.0.0
docker push codelibs/unidic-neologd-build:1.0.0
```
