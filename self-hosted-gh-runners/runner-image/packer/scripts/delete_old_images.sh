#!/bin/bash

echo "Get Image IDs from Name"
IMAGE_IDS=$( echo $(openstack image list --name "$IMAGE_NAME" -f json) | jq -r '.[].ID')

echo "Get Image Info from IDs"
IMAGES_INFO_JSON=$(
  for IMAGE in $IMAGE_IDS; do
    openstack image show "$IMAGE" -f json
  done | jq -s '.'
)

echo "Check No. of Images"
IMAGE_COUNT=$(echo "$IMAGES_INFO_JSON" | jq 'length')
if [[ "$IMAGE_COUNT" -le 1 ]]; then
  echo "Nothing to delete (found $IMAGE_COUNT image)."
  exit 0
fi

echo "Filter for oldest Images"
IMAGE_IDS_TO_DELETE=$(echo "$IMAGES_INFO_JSON" \
  | jq -r 'sort_by(.created_at) | .[:-1] | .[].id')

echo "Deleting $((IMAGE_COUNT - 1)) old images"
for IMAGE_ID in $IMAGE_IDS_TO_DELETE; do
  openstack image delete "$IMAGE_ID"
done

echo "Old Images deleted"