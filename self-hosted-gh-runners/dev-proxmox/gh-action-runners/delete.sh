#!/usr/bin/env bash
set -euo pipefail
 
CONTROLLER_NAMESPACE="arc-gh-controller"
RUNNER_NAMESPACE="arc-gh-runners"
 
helm uninstall arc-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --debug || echo "arc-runner-set not installed, skipping"
 
helm uninstall arc-dind-runner-set \
  --namespace "${RUNNER_NAMESPACE}" \
  --debug || echo "arc-dind-runner-set not installed, skipping"
 

echo "Waiting for scale set resources to be cleaned up..."
for i in $(seq 1 30); do
  remaining=$(kubectl get autoscalingrunnersets -n "${RUNNER_NAMESPACE}" \
    --no-headers 2>/dev/null | wc -l)
  [ "${remaining}" -eq 0 ] && break
  sleep 5
done
 
if [ "${remaining:-0}" -ne 0 ]; then
  echo "WARNING: AutoscalingRunnerSets still present after 150s:"
  kubectl get autoscalingrunnersets -n "${RUNNER_NAMESPACE}"
  echo "Controller may be unhealthy. Investigate before proceeding, or"
  echo "resources will need manual finalizer removal."
  exit 1
fi
 

helm uninstall arc \
  --namespace "${CONTROLLER_NAMESPACE}" \
  --wait || echo "arc controller not installed, skipping"
 


kubectl delete secret isisbusapps-gh-runners \
  --namespace "${RUNNER_NAMESPACE}" --ignore-not-found
 

kubectl delete ephemeralrunners --all -n "${RUNNER_NAMESPACE}" \
  --ignore-not-found 2>/dev/null || true
kubectl delete pvc --all -n "${RUNNER_NAMESPACE}" --ignore-not-found
 

The controller chart installs CRDs, but Helm does not remove CRDs on
uninstall by design. Deleting them removes ALL ARC resources cluster-wide,
so only do this if no other ARC install exists on the cluster.
kubectl delete crd \
  autoscalinglisteners.actions.github.com \
  autoscalingrunnersets.actions.github.com \
  ephemeralrunners.actions.github.com \
  ephemeralrunnersets.actions.github.com \
  --ignore-not-found
 

kubectl delete namespace "${RUNNER_NAMESPACE}" --ignore-not-found
kubectl delete namespace "${CONTROLLER_NAMESPACE}" --ignore-not-found
 

helm list -A | grep -E 'arc' || echo "No ARC helm releases remain."
kubectl get namespaces | grep -E 'arc-gh' || echo "Namespaces removed."