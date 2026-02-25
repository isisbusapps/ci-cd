# ci-cd

Centralised CI/CD configuration for the Users & Auth (U&A) team at isisbusapps. Contains reusable GitHub Actions workflows and infrastructure-as-code for self-hosted runners.

---

## Reusable Workflows

Reusable workflows live under `.github/workflows/` and are called via `workflow_call` from app repos. This means build logic lives in one place — updating a workflow here updates all callers automatically.

### `dev-build-reusable-workflow.yaml`

Builds and pushes a container image tagged `:dev`, then updates the image digest in the GitOps repo.

**Triggered by:** `push` to `main` (full run) or `pull_request` (build only, no push, no GitOps update).

**Inputs:**

| Input | Required | Default | Description |
|---|---|---|---|
| `image-name` | yes | — | Short image name, e.g. `auth-service` |
| `app-name` | yes | — | Human-readable name used in commit messages |
| `gitops-patch-path` | yes | — | Path in the GitOps repo to the dev `patch-image.yml` |
| `use-dockerhub-mirror` | no | `false` | Route Docker Hub pulls through `dockerhub.stfc.ac.uk` |
| `registry` | no | `ghcr.io` | Container registry to push to |
| `gitops-repo` | no | `isisbusapps/gitops` | GitOps repository to update |

**Secrets:**

| Secret | Required | Description |
|---|---|---|
| `workflow-token` | yes | PAT with `repo` + `workflow` scope for the GitOps repo |

**Example caller:**

```yaml
jobs:
  dev-build:
    uses: isisbusapps/ci-cd/.github/workflows/dev-build-reusable-workflow.yaml@main
    with:
      image-name: auth-service
      app-name: Auth Service
      gitops-patch-path: components/ua/auth-service/overlays/dev/patch-image.yml
      use-dockerhub-mirror: true
    secrets:
      workflow-token: ${{ secrets.WORKFLOW_TOKEN }}
```

---

### `build-and-prepare-release-reusable-workflow.yaml`

Builds and pushes a versioned container image, then prepares a release: creates a GitOps branch, tags the source repo, generates a changelog, creates a GitHub pre-release, and optionally opens a hotfix backport PR.

**Triggered by:** `workflow_dispatch` in the calling repo.

**Inputs:**

| Input | Required | Default | Description |
|---|---|---|---|
| `image-name` | yes | — | Short image name, e.g. `auth-service` |
| `app-name` | yes | — | Human-readable name used in commit messages |
| `gitops-patch-path` | yes | — | Path in the GitOps repo to the prod `patch-image.yml` |
| `release-version` | yes | — | Semver string **without** `v` prefix, e.g. `1.2.3` |
| `is-hotfix` | no | `false` | If `true`, opens a PR to merge the hotfix branch back into the default branch |
| `use-dockerhub-mirror` | no | `false` | Route Docker Hub pulls through `dockerhub.stfc.ac.uk` |
| `registry` | no | `ghcr.io` | Container registry to push to |
| `gitops-repo` | no | `isisbusapps/gitops` | GitOps repository to update |

**Secrets:**

| Secret | Required | Description |
|---|---|---|
| `workflow-token` | yes | PAT with `repo` + `workflow` scope for the GitOps repo |

**Jobs run:**

1. `build_and_push` — builds and pushes `<registry>/<owner>/<image-name>:<version>`
2. `update_gitops` — creates a `release/<owner>/<image-name>-<version>` branch in the GitOps repo with the updated image digest and version comment
3. `trigger_pr` — triggers the `create-release-pr.yaml` workflow in the GitOps repo
4. `create_tags` — tags the source repo with `<version>` and `latest`
5. `create_release` — generates a changelog from `.github/release-changelog-config.json` in the calling repo and creates a GitHub pre-release
6. `open_hotfix_pr` _(if `is-hotfix: true`)_ — opens a PR targeting the default branch

**Example caller:**

```yaml
jobs:
  release:
    uses: isisbusapps/ci-cd/.github/workflows/build-and-prepare-release-reusable-workflow.yaml@main
    with:
      image-name: auth-service
      app-name: Auth Service
      gitops-patch-path: components/ua/auth-service/overlays/prod/patch-image.yml
      release-version: ${{ inputs.releaseVersion }}
      is-hotfix: ${{ inputs.isHotfix }}
      use-dockerhub-mirror: true
    secrets:
      workflow-token: ${{ secrets.WORKFLOW_TOKEN }}
```

---

## Changelog Config

The release workflow reads `.github/release-changelog-config.json` from the **calling repo** to determine changelog categories and labels. Each app repo owns its own config, so teams can independently control which PR labels appear in their release notes.

If the file is absent, `mikepenz/release-changelog-builder-action` falls back to its defaults.

---

## Notes

- **`secrets.GITHUB_TOKEN`** is not passed explicitly — in a `workflow_call` context, the reusable workflow automatically uses the calling repo's token, which has `packages: write` for `ghcr.io/isisbusapps/*`.
- **Release versions** must be bare semver (e.g. `1.2.3`) with no `v` prefix. Two tags are created: `1.2.3` and `latest`.
- **Pinning:** callers reference `@main`. For stricter change control, pin to a tag or SHA instead.

---

## Repository Structure

```
.github/
  dependabot.yml                                    # Dependabot config (daily, cooldown: 1d default / 2d minor / 7d major)
  workflows/
    dev-build-reusable-workflow.yaml                # Reusable: dev build + GitOps update
    build-and-prepare-release-reusable-workflow.yaml  # Reusable: versioned build + full release prep
self-hosted-gh-runners/                             # Docs and (future) Terraform for ephemeral OpenStack runners
```
