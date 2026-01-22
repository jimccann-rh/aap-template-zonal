# Simple AAP Template Runner

This is a simple, focused playbook for running existing AAP job templates via SSO authentication.

## Quick Start

### 1. Install Ansible Collections

```bash
cd /home/jimccann/cursor/ansible
ansible-galaxy collection install -r requirements.yml
```

### 2. Set Environment Variables

**Option A: Use the setup script**

```bash
# Edit setup_env.sh with your values, then:
source setup_env.sh
```

**Option B: Set manually**

```bash
export AAP_URL="https://your-aap-instance.com"
export AAP_TOKEN="your-oauth-token-here"
export AAP_TEMPLATE_NAME="vSphere-Nested-DEVQE-static-autoscript"
export VC_STATIC_IP="192.168.1.100"  # Optional: passed as extra variable to template
```

### 3. Get Your SSO Token

Since you're using SSO, you need to create a Personal Access Token (PAT):

1. Log into AAP via SSO
2. Go to **User → Tokens** (or your profile → Tokens)
3. Click **Create Token**
4. Provide a description (e.g., "Ansible Automation")
5. Select scope: **Write** (or Read/Write)
6. **Copy the token immediately** (you'll only see it once!)
7. Set it as `AAP_TOKEN` environment variable

**Important:** Make sure "Allow external users to create OAuth2 tokens" is enabled in AAP settings:
- Go to **Settings → Miscellaneous Authentication**
- Enable the setting if it's not already enabled

### 4. Run the Playbook

```bash
# Run with template from environment variable
ansible-playbook run_aap_template.yml

# Or override template name
ansible-playbook run_aap_template.yml -e "template_name=My Template"

# With extra variables
ansible-playbook run_aap_template.yml \
  -e "template_name=Deploy App" \
  -e 'extra_vars={"version": "1.2.3", "environment": "production"}'
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `AAP_URL` | Yes | Your AAP instance URL (e.g., https://aap.example.com) |
| `AAP_TOKEN` | Yes | OAuth2 token or Personal Access Token |
| `AAP_TEMPLATE_NAME` | No* | Default template name to run |
| `AAP_VERIFY_SSL` | No | SSL verification (true/false, default: true) |
| `VC_STATIC_IP` | No | VC Static IP address - passed as `vc_static_ip` extra variable |
| `VC_FACT_PASSWORD` | Yes | Password - passed as `vc_fact_password` extra variable |
| `VERSION` | Yes | Version - passed as `version` extra variable |
| `TARGET_HOSTS` | Yes | Target hosts (space-separated) - passed as `target_hosts` extra variable |
| `TARGET_VCS` | Yes | Target VCs (comma-separated) - passed as `target_vcs` extra variable |
| `HOWMANYDAYS` | Yes | Number of days - passed as `howmanydays` extra variable |
| `VC_STATIC` | Yes | VC Static value - passed as `vc_static` extra variable |

*If not set, you must provide `template_name` via `-e` flag

## Examples

### Basic Usage

```bash
# Set environment variables
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="abc123xyz..."
export AAP_TEMPLATE_NAME="vSphere-Nested-DEVQE-static-autoscript"
export VC_STATIC_IP="10.185.104.20"
export VC_FACT_PASSWORD="your-password"
export VERSION="your-version"
export TARGET_HOSTS="host1 host2"  # Space-separated (text area field)
export TARGET_VCS="vc1,vc2"
export HOWMANYDAYS="30"
export VC_STATIC="your-vc-static-value"

# Run the playbook
ansible-playbook run_aap_template.yml
```

All environment variables are automatically passed to the template as extra variables with the same names (lowercase for most, except `VC_STATIC_IP` becomes `vc_static_ip`).

### With Custom Template

```bash
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="abc123xyz..."

# Override template name
ansible-playbook run_aap_template.yml -e "template_name=Backup Database"
```

### With Additional Extra Variables

```bash
export AAP_URL="https://aap.example.com"
export AAP_TOKEN="abc123xyz..."
export VC_FACT_PASSWORD="password"
export VERSION="1.0"
export TARGET_HOSTS="host1 host2"  # Space-separated (text area field)
export TARGET_VCS="vc1"
export HOWMANYDAYS="30"
export VC_STATIC="value"
export VC_STATIC_IP="10.185.104.20"

# All required variables are automatically included from environment variables
# You can add additional variables via extra_vars_override
ansible-playbook run_aap_template.yml \
  -e "template_name=Deploy App" \
  -e 'extra_vars_override={"custom_var": "value"}'
```

**Note:** All required variables from environment variables are automatically included. You can add additional variables via `extra_vars_override`.

### Without Waiting (Fire and Forget)

```bash
ansible-playbook run_aap_template.yml \
  -e "template_name=Long Running Job" \
  -e "wait_for_completion=false"
```

### Custom Timeout

```bash
ansible-playbook run_aap_template.yml \
  -e "template_name=My Template" \
  -e "job_timeout=7200"  # 2 hours
```

### Verbose Output

```bash
ansible-playbook run_aap_template.yml \
  -e "template_name=My Template" \
  -e "verbosity=2"  # 0-4, higher = more verbose
```

## Playbook Variables

You can override these via `-e` flag:

- `template_name` - Template name to run
- `extra_vars_override` - Additional extra variables (JSON format) - merged with `vc_static_ip` from `VC_STATIC_IP` env var
- `wait_for_completion` - Wait for job to finish (true/false, default: true)
- `job_timeout` - Timeout in seconds (default: 3600)
- `verbosity` - Verbosity level 0-4 (default: 0)

**Note:** The `vc_static_ip` variable is automatically included in extra_vars from the `VC_STATIC_IP` environment variable. If you need to add more variables, use `extra_vars_override` which will be merged with `vc_static_ip`.

## Output

The playbook will display:

- Job ID
- Job status
- Start/finish times
- Elapsed time
- Direct URL to view job in AAP UI
- Job output (if waiting for completion)

## Troubleshooting

### Error: Missing required environment variables

Make sure you've set:
- `AAP_URL`
- `AAP_TOKEN`
- `AAP_TEMPLATE_NAME` (or use `-e template_name=...`)

### Error: Collection not found

Install the collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

### Error: Authentication failed

- Verify your token is valid and not expired
- Check that "Allow external users to create OAuth2 tokens" is enabled in AAP
- Ensure your token has the correct scope (read/write)

### Error: Template not found

- Verify the template name is correct
- List available templates first:
  ```bash
  ansible-playbook playbooks/list_job_templates.yml
  ```

### Error: SSL certificate verification failed

Set `AAP_VERIFY_SSL=false`:
```bash
export AAP_VERIFY_SSL="false"
```

## Security Notes

1. **Never commit tokens to version control**
   - Use environment variables
   - Add `.env` files to `.gitignore`
   - Use secrets management tools in production

2. **Token Storage**
   - Store tokens in secure vaults (Ansible Vault, HashiCorp Vault, etc.)
   - Rotate tokens regularly
   - Use minimal required scope

3. **Environment Variables**
   - Consider using `.env` files with `source` command
   - Or use Ansible Vault for sensitive data

## Next Steps

- See `README_ANSIBLE.md` for more advanced playbooks and roles
- Check `examples/` directory for complex deployment scenarios
- Review `aap_api_usage.md` for Python API client documentation
