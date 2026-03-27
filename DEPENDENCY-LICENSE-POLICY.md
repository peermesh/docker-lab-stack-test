# Dependency and distribution license policy

This document explains how the **project license** (`LICENSE`, PolyForm Noncommercial 1.0.0) relates to **third-party** components. It is guidance for maintainers and distributors; it is not legal advice.

## What the project license covers

- **Covers:** Original creative work committed in this repository by the copyright holder (see [`COPYRIGHT`](COPYRIGHT))—for example Compose integration, tests, docs, and layout under this repo that are not substantially copied from third-party sources.
- **Does not replace:** Licenses that apply to **upstream application images and services** referenced by patterns, dependencies, or base images.

## What stays under third-party terms

- **Each pattern’s application stack** (for example federated social, blog, or automation services) remains under its upstream project license when you run or redistribute those images or binaries.
- **Container images** pulled from registries remain under their respective upstream licenses.
- **PeerMesh core** or other Git dependencies are governed by their own repository licenses when used as separate projects.

## Obligations checklist (typical)

When you distribute this project or artifacts built from it, verify compliance for **each** third-party component you ship or cause to be pulled:

- **Attribution:** Preserve copyright notices and license texts where required.
- **License notices:** Include or link to the license for copyleft or notice-dependent licenses when you distribute corresponding binaries or sources.
- **Source offer:** For licenses that require it when distributing combined works, provide source or a written offer as required by that license.
- **Trademarks:** Do not imply endorsement; respect upstream trademark policies.

## Distribution: repos, containers, and images

- **Source repository:** Keep [`LICENSE`](LICENSE), [`COPYRIGHT`](COPYRIGHT), [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md), and this file accurate as the bill of materials evolves.
- **Container images you build:** Document base images and installed packages; reproduce required notices as appropriate.
- **Pre-built images you publish:** Prefer scanning tools (SBOM, SPDX, CycloneDX) and attach a third-party notice bundle for any image you ship to customers.

## Relationship to PolyForm Noncommercial

The PolyForm Noncommercial terms apply to **this project’s original work** as licensed by the copyright holder. Third-party components are **not** relicensed by PolyForm; you must comply with their license terms in parallel.
