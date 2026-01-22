# Ansible Automation Platform (AAP) - Ansible Playbooks

This directory contains Ansible playbooks and roles for interacting with the Ansible Automation Platform API. These playbooks use the `awx.awx` collection to manage AAP resources.

## Prerequisites

1. **Install Ansible Collections**
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Configure AAP Connection**
   
   Option A: Environment Variables (Recommended)
   ```bash
   export AAP_URL="https://your-aap-instance.com"
   export AAP_TOKEN="your-oauth-token-here"
   export AAP_VERIFY_SSL="true"
   ```

   Option B: Edit `group_vars/all.yml` or `inventory.yml`

3. **Enable Token Creation for SSO Users**
   - In AAP, go to **Settings → Miscellaneous Authentication**
   - Enable **"Allow external users to create OAuth2 tokens"**
   - Create a Personal Access Token (PAT) via the web UI

## Quick Start

### List Available Job Templates

```bash
ansible-playbook playbooks/list_job_templates.yml
```

### Launch a Job Template

```bash
# Launch by name
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=My Template" \
  -e "wait=true"

# Launch by ID with extra variables
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_id=42" \
  -e 'extra_vars={"version": "1.2.3", "environment": "production"}' \
  -e "wait=true"
```

### Check Job Status

```bash
ansible-playbook playbooks/get_job_status.yml -e "job_id=123"
```

### Wait for Job Completion

```bash
ansible-playbook playbooks/wait_for_job.yml -e "job_id=123"
```

## Playbooks

### `playbooks/launch_job_template.yml`

Launches a job template in AAP.

**Variables:**
- `job_template_name` or `job_template_id` (required)
- `extra_vars` (dict, optional)
- `inventory_name` or `inventory_id` (optional)
- `limit` (string, optional)
- `verbosity` (0-4, default: 0)
- `wait_for_completion` (bool, default: true)
- `job_timeout` (seconds, default: 3600)
- `credentials` (list, optional)
- `job_tags` (string, optional)
- `skip_tags` (string, optional)

**Example:**
```bash
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=Deploy App" \
  -e 'extra_vars={"version": "2.0.0"}' \
  -e "limit=web-servers" \
  -e "verbosity=2" \
  -e "wait=true"
```

### `playbooks/list_job_templates.yml`

Lists all available job templates in AAP.

**Example:**
```bash
ansible-playbook playbooks/list_job_templates.yml
```

### `playbooks/get_job_status.yml`

Retrieves the status and output of a specific job.

**Variables:**
- `job_id` (required)

**Example:**
```bash
ansible-playbook playbooks/get_job_status.yml -e "job_id=123"
```

### `playbooks/wait_for_job.yml`

Waits for a job to complete and displays results.

**Variables:**
- `job_id` (required)
- `timeout` (seconds, default: 3600)
- `poll_interval` (seconds, default: 5)

**Example:**
```bash
ansible-playbook playbooks/wait_for_job.yml \
  -e "job_id=123" \
  -e "timeout=1800"
```

## Roles

### `roles/aap_job_launch/`

A reusable role for launching job templates. Can be included in other playbooks.

**Usage:**
```yaml
- hosts: localhost
  roles:
    - role: aap_job_launch
      vars:
        job_template_name: "My Template"
        extra_vars:
          key: "value"
        wait_for_completion: true
```

See `roles/aap_job_launch/README.md` for detailed documentation.

## Using the Role in Custom Playbooks

```yaml
---
- name: Deploy Application
  hosts: localhost
  gather_facts: false
  vars:
    app_version: "2.0.0"
    deploy_environment: "production"

  tasks:
    - name: Launch deployment job
      include_role:
        name: aap_job_launch
      vars:
        job_template_name: "Deploy Application"
        extra_vars:
          version: "{{ app_version }}"
          environment: "{{ deploy_environment }}"
        wait_for_completion: true

    - name: Display results
      debug:
        msg: "Deployment job {{ aap_job_id }} completed with status {{ aap_job_status }}"
```

## Configuration

### Environment Variables

The playbooks automatically use these environment variables if set:

- `AAP_URL` - AAP controller URL
- `AAP_TOKEN` - OAuth2 token or PAT
- `AAP_USERNAME` - Username (if not using token)
- `AAP_PASSWORD` - Password (if not using token)
- `AAP_VERIFY_SSL` - SSL verification (true/false)

### Inventory Variables

You can also configure these in `inventory.yml` or `group_vars/all.yml`:

```yaml
controller_host: "https://your-aap-instance.com"
controller_token: "your-token-here"
controller_verify_ssl: true
```

## Authentication Methods

### Method 1: Personal Access Token (PAT) - Recommended for SSO

1. Log into AAP via SSO
2. Go to **User → Tokens**
3. Create a new token
4. Use it via environment variable: `export AAP_TOKEN="your-token"`

### Method 2: Username/Password

Set environment variables:
```bash
export AAP_USERNAME="your-username"
export AAP_PASSWORD="your-password"
```

**Note:** This may not work with SSO-only authentication.

## Advanced Examples

### Launch with Multiple Extra Variables

```bash
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=Deploy" \
  -e 'extra_vars={"version": "1.0", "env": "prod", "region": "us-east-1"}' \
  -e "wait=true"
```

### Launch with Inventory Override

```bash
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=My Template" \
  -e "inventory_name=Staging Inventory" \
  -e "wait=true"
```

### Launch with Host Limit

```bash
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=My Template" \
  -e "limit=web-servers:!maintenance" \
  -e "wait=true"
```

### Launch with Tags

```bash
ansible-playbook playbooks/launch_job_template.yml \
  -e "job_template_name=My Template" \
  -e "job_tags=deploy,config" \
  -e "skip_tags=test" \
  -e "wait=true"
```

## Troubleshooting

### Error: Collection not found

Install the required collections:
```bash
ansible-galaxy collection install -r requirements.yml
```

### Error: Authentication failed

- Verify your token is valid and not expired
- Check that "Allow external users to create OAuth2 tokens" is enabled
- Ensure your token has the correct scope (read/write)

### Error: Job template not found

- Verify the template name or ID is correct
- Check that you have permissions to view the template
- List templates first: `ansible-playbook playbooks/list_job_templates.yml`

### Error: SSL certificate verification failed

Set `AAP_VERIFY_SSL=false` or `controller_verify_ssl: false` in your configuration.

## Comparison: Python vs Ansible

### Python Script (`aap_api_client.py`)
- Direct API calls using `requests` library
- More control over HTTP requests
- Good for custom integrations and scripts
- Requires Python dependencies

### Ansible Playbooks
- Uses `awx.awx` collection modules
- Idempotent and declarative
- Better integration with Ansible ecosystem
- Can be used in larger automation workflows
- Requires Ansible and collections

Both approaches are valid - choose based on your use case!

## Additional Resources

- [AWX Collection Documentation](https://docs.ansible.com/ansible/latest/collections/awx/awx/)
- [AAP API Documentation](https://docs.ansible.com/automation-controller/latest/html/controllerapi/index.html)
- [Ansible Playbook Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
