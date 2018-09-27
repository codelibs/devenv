# Unidic Build Environment for Docker

## Build Docker Image

```
docker build --rm -t codelibs/unidic-build .
```

## Run Docker Image

```
docker run -t --rm -v `readlink -f ../data/`:/data/ codelibs/unidic-build:latest
```

### Push Latest Image

```
docker push codelibs/unidic-build:latest
```

### Push Release Images

```
docker tag codelibs/unidic-build codelibs/unidic-build:1.0.0
docker push codelibs/unidic-build:1.0.0
```
