#!/bin/bash
echo "📦 Installing required Ansible collections..."
ansible-galaxy collection install community.aws

echo "✅ Setup complete!"
echo "📝 Please update the following files with your actual values:"
echo "   - inventories/production/group_vars/all.yml"
echo "   - playbooks/vars/wordpress.yml" 
echo "   - roles/wordpress/tasks/main.yml (replace YOUR_ACCOUNT_ID)"
echo ""
echo "🚀 To deploy: ansible-playbook playbooks/deploy-wordpress.yml"