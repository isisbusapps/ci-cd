#!/usr/bin/env bash
set -euo pipefail

CONTROLLER_NAMESPACE="arc-gh-controller"
RUNNER_NAMESPACE="arc-gh-runners"
CHART_VERSION="0.14.2"

kubectl get namespace "${RUNNER_NAMESPACE}" >/dev/null 2>&1 || \
  kubectl create namespace "${RUNNER_NAMESPACE}"

kubectl get namespace "${CONTROLLER_NAMESPACE}" >/dev/null 2>&1 || \
  kubectl create namespace "${CONTROLLER_NAMESPACE}"

kubectl create secret generic isisbusapps-gh-runners \
  --namespace "${RUNNER_NAMESPACE}" \
  --from-literal=github_token="${ACCESS_TOKEN}" || echo "Secret exists, or errored on creation"

helm upgrade --install arc \
  --namespace "${CONTROLLER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f controller-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

helm upgrade --install arc-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f runner-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

helm upgrade --install arc-dind-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f docker-in-docker-runner-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get pods -n "${CONTROLLER_NAMESPACE}" \
  -l 'app.kubernetes.io/part-of in (gha-rs-controller, gha-runner-scale-set)'
kubectl get autoscalingrunnersets -n "${CONTROLLER_NAMESPACE}"

kubectl get pods -n "${RUNNER_NAMESPACE}" \
  -l 'app.kubernetes.io/part-of in (gha-rs-controller, gha-runner-scale-set)'
kubectl get autoscalingrunnersets -n "${RUNNER_NAMESPACE}"

#!/usr/bin/env bash
set -euo pipefail

CONTROLLER_NAMESPACE="arc-gh-controller"
RUNNER_NAMESPACE="arc-gh-runners"
CHART_VERSION="0.14.2"

kubectl get namespace "${RUNNER_NAMESPACE}" >/dev/null 2>&1 || \
  kubectl create namespace "${RUNNER_NAMESPACE}"

kubectl get namespace "${CONTROLLER_NAMESPACE}" >/dev/null 2>&1 || \
  kubectl create namespace "${CONTROLLER_NAMESPACE}"

kubectl create secret generic isisbusapps-gh-runners \
  --namespace "${RUNNER_NAMESPACE}" \
  --from-literal=github_token="${ACCESS_TOKEN}" || echo "Secret exists, or errored on creation"

# Hook extension template injected into every kubernetes-mode job container.
# Must exist before the runner-set chart upgrade: runner pods mount it as a volume.
kubectl apply --namespace "${RUNNER_NAMESPACE}" -f hook-extension.yaml

helm upgrade --install arc \
  --namespace "${CONTROLLER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f controller-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

helm upgrade --install arc-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f runner-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

helm upgrade --install arc-dind-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --version "${CHART_VERSION}" \
  -f docker-in-docker-runner-set-vaules.yaml \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get pods -n "${CONTROLLER_NAMESPACE}" \
  -l 'app.kubernetes.io/part-of in (gha-rs-controller, gha-runner-scale-set)'
kubectl get autoscalingrunnersets -n "${CONTROLLER_NAMESPACE}"

kubectl get pods -n "${RUNNER_NAMESPACE}" \
  -l 'app.kubernetes.io/part-of in (gha-rs-controller, gha-runner-scale-set)'
kubectl get autoscalingrunnersets -n "${RUNNER_NAMESPACE}"