#!/bin/bash
set -e

# install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io git jq

# install Azure DevOps agent prereqs
apt-get install -y liblttng-ust0 libkrb5-3 zlib1g libicu66 libssl1.1 libunwind8

# create directory for agent
mkdir -p /azp/agent
cd /azp/agent

# NOTE: The following placeholders must be replaced with your AZDO org URL and PAT, or you can register the agent manually
AGENT_VERSION="2.220.2"
AGENT_TAR="v${AGENT_VERSION//./_}.tar.gz"

# download latest agent (using official distribution)
curl -LsS https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz -o agent.tar.gz

# extract
mkdir agent && tar -xzf agent.tar.gz -C agent --strip-components=1
chown -R ubuntu:ubuntu /azp

# (Do not auto-configure using PAT here in user_data; instead provide instructions to configure the agent securely.)
# Create a systemd service to run the agent when configured
cat > /etc/systemd/system/azp-agent.service <<'EOF'
[Unit]
Description=Azure Pipelines Agent
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/azp/agent
ExecStart=/bin/bash /azp/agent/run.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable azp-agent.service

# ensure ec2 instance has correct permissions to ECR via instance profile
usermod -aG docker ubuntu || true

# finish