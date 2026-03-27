# Third-party notices

## Scope

This repository combines **original PeerMesh materials** (licensed under PolyForm Noncommercial 1.0.0; see [`LICENSE`](LICENSE)) with **third-party components**. Third-party software, data, and container images **remain under their own licenses**. The project license does **not** apply to them and does **not** grant rights to third-party trademarks.

Nothing in this file is a complete inventory; it lists **known categories** and **examples** from documented patterns. Maintain a full bill of materials for production distributions (for example via SBOM tools). See [`DEPENDENCY-LICENSE-POLICY.md`](DEPENDENCY-LICENSE-POLICY.md).

## Upstream application patterns

Pattern documentation under `patterns/` (for example GoToSocial, WriteFreely, PeerTube, Listmonk, ActivityPods, n8n, Pixelfed, Castopod, Manyfold, rss2bsky) refers to **separate upstream projects**. When you pull or run their container images or binaries, **their** licenses and notices apply to those components.

## PeerMesh core dependency

This bundle integrates with [peermesh/core](https://github.com/peermesh/core) infrastructure; that repository has its own license and notices.

## Container images and runtime services

Compose files pull upstream images from public registries. Each image remains under its **upstream** license (see registry pages and image labels).

## Placeholder: lockfiles and scripts

- **Placeholder —** If you add root-level `package.json`, `go.mod`, `requirements.txt`, or similar, enumerate ecosystems here and attach license audit outputs.

## Placeholder: vendored or submodule code

- **Placeholder —** List Git submodules, copied snippets, or vendored trees with pointers to their LICENSE files.
