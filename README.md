# Gigamonkey_env

`Gigamonkey_env` builds the Docker image used as the runtime/build environment for [Gigamonkey](https://github.com/Gigamonkey-BSV/Gigamonkey) and the projects that depend on it. It layers specific, pinned versions of Gigamonkey's C++ dependencies — [`data`](https://github.com/DanielKrawisz/data), [`net`](https://github.com/DanielKrawisz/net), and [`Gigamonkey`](https://github.com/Gigamonkey-BSV/Gigamonkey) itself — on top of the `gigamonkey/gigamonkey-base-dev` base image, so that downstream projects can build against a known-good, reproducible environment instead of building these libraries from scratch every time.

The resulting image is published to Docker Hub as **`gigamonkey/gigamonkey-lib`**.

## How it works

- **`versions.json`** pins the exact commit for each dependency:
  - `DATA_VERSION`
  - `NET_VERSION`
  - `GIGAMONKEY_VERSION`
- **`Dockerfile`** clones `data`, `net`, and `Gigamonkey`, checks out the commit specified for each in `versions.json`, then builds and installs each one in order using CMake/Ninja.
- **`.github/workflows/new_base.yml`** builds and publishes the image whenever a tag matching `v*` is pushed. It:
  1. Builds the image for `linux/amd64` and `linux/arm64` (using QEMU + Docker Buildx).
  2. Reads `versions.json` and passes `DATA_VERSION` / `GIGAMONKEY_VERSION` in as build args.
  3. Pushes both per-platform digests to Docker Hub, then merges them into a single multi-arch manifest tagged and pushed to `gigamonkey/gigamonkey-lib`.

## Updating

To bump the environment to newer versions of the dependencies:

1. **Update `versions.json`** with the new commit hash(es) for whichever of `DATA_VERSION`, `NET_VERSION`, and/or `GIGAMONKEY_VERSION` need to change.
2. **Check the base image version.** The `Dockerfile`'s `FROM` line pins a specific tag of `gigamonkey/gigamonkey-base-dev` (e.g. `v2.3.1`), which is built from [Gigamonkey-BSV/Docker-Base](https://github.com/Gigamonkey-BSV/Docker-Base). If that repo has published a newer base image, bump the tag in the `FROM` line here to match before tagging a new release here — otherwise the build will silently keep using the old base image.
3. **Commit the change(s)** to `main` (or merge them in via PR).
4. **Create a new tag** following the `v*` pattern (e.g. `v2.8`) and push it:
   ```bash
   git tag v2.8
   git push origin v2.8
   ```
5. Pushing the tag triggers the **Publish Docker Image** GitHub Actions workflow, which builds the multi-arch image and pushes it to Docker Hub as `gigamonkey/gigamonkey-lib:v2.8` (plus any other tags `docker/metadata-action` derives, e.g. `latest`).

No manual `docker build`/`docker push` steps are required — pushing the tag is sufficient as long as the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets are configured.

## Requirements for maintainers

- Repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` must be set for the publish workflow to authenticate with Docker Hub.
- Tags must start with `v` (e.g. `v2.8`, `v3.0.1`) to trigger a build — other pushes do not trigger publishing.
