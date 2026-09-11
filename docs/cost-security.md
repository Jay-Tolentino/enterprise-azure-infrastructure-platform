# Cost and Security

## Cost Management

The platform was designed around an Azure for Students subscription, so operating cost was considered throughout the project.

### Cost Controls

- Development-sized Linux virtual machine
- VM deallocated when it is not actively being used
- Standard LRS storage for Terraform remote state
- Single development environment
- Limited monitoring scope
- No Azure Bastion deployment in the lab environment
- Infrastructure can be recreated through Terraform when required

Deallocating the VM stops VM compute charges.

Other resources can continue to have small costs while the VM is deallocated, including:

- managed disks
- static public IP
- Azure Storage
- Log Analytics ingestion and retention

## Security Controls

The environment implements multiple security controls.

### Authentication

- SSH public-key authentication
- Password authentication disabled for the Linux VM
- GitHub Actions authentication through OpenID Connect
- No long-lived Azure client secret stored in GitHub

### Network Security

- Azure Network Security Group
- SSH limited to a specific source CIDR
- Dedicated application subnet
- Explicit inbound security rule

### Identity

Two managed identity patterns are demonstrated:

1. A user-assigned managed identity for GitHub Actions deployment.
2. A system-assigned managed identity attached to the Linux VM.

Azure RBAC controls what each identity can access.

### Secrets Management

Azure Key Vault is deployed through Terraform.

The VM managed identity receives the:

```text
Key Vault Secrets User
```

role at the Key Vault scope.

This supports secret retrieval through identity rather than embedded Azure credentials.

### Terraform State Security

Terraform state is stored in Azure Blob Storage.

The storage account uses:

- HTTPS-only traffic
- TLS 1.2 minimum
- public blob access disabled
- Microsoft Entra ID authorization
- Azure RBAC
- remote state locking

Terraform state files are excluded from Git.

## Production Improvements

A larger production environment could add:

- Azure Bastion
- VPN or ExpressRoute
- private endpoints
- private DNS
- Azure Firewall
- additional subnet segmentation
- separate development, staging, and production subscriptions
- availability zones
- VM backup policies
- action groups for operational alerts
- centralized security monitoring
- Microsoft Defender for Cloud
- stricter RBAC roles
- automated policy enforcement with Azure Policy