#!/bin/bash

delete_images() {
  local IMAGE_IDS=$( echo $1 | jq -r 'join(" ")')
  local IMAGE_COUNT=$2

  echo "Get Image Info from IDs"
  IMAGE_INFO=$(
    for IMAGE in $IMAGE_IDS; do
      openstack image show "$IMAGE" -f json
    done | jq -s '.'
  )

  echo "Filter for oldest Images"
  DELETE_IMAGE_IDS=$(echo "$IMAGE_INFO" \
    | jq -r 'sort_by(.created_at) | .[:-1] | .[].id')

  echo "Deleting $((IMAGE_COUNT - 1)) old images"
  for IMAGE_ID in $DELETE_IMAGE_IDS; do
    openstack image delete "$IMAGE_ID"
  done
}

echo "Get Image IDs from Name"
RUNNER_IMAGE_IDS=$( echo $(openstack image list --name "$IMAGE_NAME" -f json) | jq -r '[.[].ID]')
ANSIBLE_IMAGE_IDS=$( echo $(openstack image list --name "ua-ansible-image" -f json) | jq -r '[.[].ID]')

echo "Check No. of Images"
RUNNER_IMAGE_COUNT=$(echo "$RUNNER_IMAGE_IDS" | jq -r 'length')
ANSIBLE_IMAGE_COUNT=$(echo "$ANSIBLE_IMAGE_IDS" | jq -r 'length')

if [[ "$RUNNER_IMAGE_COUNT" -gt 1 ]]; then
  delete_images "$RUNNER_IMAGE_IDS" "$RUNNER_IMAGE_COUNT"
else
  echo "No runner images to delete, (found $RUNNER_IMAGE_COUNT image)"
fi

if [[ "$ANSIBLE_IMAGE_COUNT" -gt 1 ]]; then
  delete_images "$ANSIBLE_IMAGE_IDS" "$ANSIBLE_IMAGE_COUNT"
else
  echo "No ansible images to delete, (found $ANSIBLE_IMAGE_COUNT image)"
fi

echo "Any old images deleted"