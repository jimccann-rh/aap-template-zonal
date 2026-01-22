#!/bin/bash
# Setup script for AAP environment variables
# 
# Usage:
#   source setup_env.sh
#   OR
#   . setup_env.sh
#
# Edit the values below with your AAP instance details

# AAP Controller URL
export AAP_URL=""

# OAuth2 Token or Personal Access Token (PAT)
# Get this from AAP UI: User -> Tokens -> Create Token
export AAP_TOKEN=""

# Optional: Template name (can also be passed via -e flag)
export AAP_TEMPLATE_NAME="vSphere-Nested-DEVQE-static-autoscript"

# Optional: SSL verification (true/false, default: true)
export AAP_VERIFY_SSL="true"

# Required variables - passed as extra variables to the template
export VC_STATIC_IP="10.185.104.20"
export VC_FACT_PASSWORD=""
export VERSION="8"
export TARGET_HOSTS="jimccann-aap-HOST1.vpshere.local jimccann-aap-HOST2.vpshere.local"
export TARGET_VCS="jimccann-aap-VC.vpshere.local"
export HOWMANYDAYS="2"
# VC_STATIC must be exactly "True" or "False" (case-sensitive)
# The playbook will normalize common values (true, false, 1, 0, yes, no) to "True" or "False"
export VC_STATIC="True"

# Display configuration (without showing token)
echo "AAP Configuration:"
echo "  URL: $AAP_URL"
echo "  Token: ${AAP_TOKEN:0:20}... (hidden)"
echo "  Template: ${AAP_TEMPLATE_NAME:-not set}"
echo "  Verify SSL: $AAP_VERIFY_SSL"
echo ""
echo "Required Variables:"
echo "  VC Static IP: ${VC_STATIC_IP:-not set}"
echo "  VC Fact Password: ${VC_FACT_PASSWORD:+SET (hidden)}${VC_FACT_PASSWORD:-not set}"
echo "  Version: ${VERSION:-not set}"
echo "  Target Hosts: ${TARGET_HOSTS:-not set}"
echo "  Target VCs: ${TARGET_VCS:-not set}"
echo "  How Many Days: ${HOWMANYDAYS:-not set}"
echo "  VC Static: ${VC_STATIC:-not set}"
echo ""
echo "To run a playbook:"
echo "  ansible-playbook run_aap_template.yml"
echo ""
echo "Or override template name:"
echo "  ansible-playbook run_aap_template.yml -e 'template_name=My Template'"

#ansible-playbook run_aap_template.yml
