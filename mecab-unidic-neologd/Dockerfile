FROM java:11

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    file \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

COPY run.sh /work/run.sh
COPY unidic.patch /work/unidic.patch
COPY fix_range.py /work/fix_range.py
CMD ["/bin/bash", "-x", "run.sh"]

