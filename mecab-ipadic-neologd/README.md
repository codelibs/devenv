# Neologd Build Environment for Docker

## Build Docker Image

```
docker build --rm -t codelibs/ipadic-neologd-build .
```

## Run Docker Image

```
docker run -t --rm -v `readlink -f ../data/`:/data/ codelibs/ipadic-neologd-build:latest
```

### Push Latest Image

```
docker push codelibs/ipadic-neologd-build:latest
```

### Push Release Images

```
docker tag codelibs/ipadic-neologd-build codelibs/ipadic-neologd-build:1.0.0
docker push codelibs/ipadic-neologd-build:1.0.0
```
