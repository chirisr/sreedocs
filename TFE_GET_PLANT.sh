#!/bin/bash

# Set the TFE API token and organization name
export TFE_TOKEN=<your-tfe-api-token>
export TFE_ORG=<your-tfe-organization-name>

# Set the workspace name and directory where the Terraform code is located
export TFE_WORKSPACE=<your-tfe-workspace-name>
export TFE_DIR=<path-to-your-terraform-code-directory>

# Create a new Terraform plan
echo "Creating a new Terraform plan..."
curl \
  --header "Authorization: Bearer $TFE_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "{\"data\":{\"attributes\":{\"is-destroy\":false},\"type\":\"plans\",\"relationships\":{\"workspace\":{\"data\":{\"type\":\"workspaces\",\"id\":\"$TFE_ORG/$TFE_WORKSPACE\"}}}}}" \
  https://app.terraform.io/api/v2/runs > /tmp/tfe-plan.json

# Extract the plan ID from the response JSON
TFE_PLAN_ID=$(cat /tmp/tfe-plan.json | jq -r '.data.id')

# Wait for the plan to finish
echo "Waiting for the Terraform plan to finish..."
while true; do
  sleep 5
  TFE_PLAN_STATUS=$(curl \
    --header "Authorization: Bearer $TFE_TOKEN" \
    --request GET \
    https://app.terraform.io/api/v2/plans/$TFE_PLAN_ID | jq -r '.data.attributes.status')
  if [ "$TFE_PLAN_STATUS" != "pending" ] && [ "$TFE_PLAN_STATUS" != "applying" ]; then
    break
  fi
done

# Print the plan status
echo "Terraform plan status: $TFE_PLAN_STATUS"
