# syntax=docker/dockerfile:1.7

FROM python:3.10-slim AS builder

ARG DEBIAN_FRONTEND=noninteractive

ENV VENV_PATH=/opt/venv \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    SETUPTOOLS_USE_DISTUTILS=stdlib \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv "${VENV_PATH}"

ENV PATH="${VENV_PATH}/bin:${PATH}"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
    pip==24.2 \
    setuptools==59.8.0 \
    wheel==0.42.0 \
    && pip install \
    Cython==3.0.8 \
    joblib==1.4.2 \
    matplotlib==3.9.1.post1 \
    netCDF4==1.6.2 \
    numpy==1.26.3 \
    pandas==2.2.2 \
    scikit-learn==1.5.1 \
    scipy==1.12.0 \
    wrapt==1.16.0 \
    xarray==2024.7.0 \
    && pip install --no-build-isolation --no-deps wrf-python==1.3.4.1

FROM python:3.10-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV APP_HOME=/workspace/GridPredict_OceanMeteo \
    VENV_PATH=/opt/venv \
    GRIDPREDICT_CONFIG=/workspace/GridPredict_OceanMeteo/HSQX_Input.json \
    GRIDPREDICT_SCRIPT=/workspace/GridPredict_OceanMeteo/HSQX.py \
    MPLCONFIGDIR=/tmp/matplotlib \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:${PATH}"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libgfortran5 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_HOME}

RUN mkdir -p \
    /workspace \
    "${APP_HOME}" \
    "${APP_HOME}/result" \
    /data/input \
    "${MPLCONFIGDIR}"

COPY --from=builder ${VENV_PATH} ${VENV_PATH}
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/run-gridpredict

VOLUME ["/workspace/GridPredict_OceanMeteo", "/data/input"]

ENTRYPOINT ["/usr/local/bin/run-gridpredict"]
CMD []
