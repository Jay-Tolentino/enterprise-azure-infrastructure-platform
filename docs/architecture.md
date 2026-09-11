# Architecture

## Platform Flow

```mermaid
flowchart LR
    DEV[Developer]
    GITHUB[GitHub Repository]
    ACTIONS[GitHub Actions]
    OIDC[GitHub OIDC]
    DEPLOYID[Azure Deployment Managed Identity]
    TERRAFORM[Terraform]
    STATE[Azure Blob Remote State]

    VNET[Virtual Network]
    SUBNET[Application Subnet]
    NSG[Network Security Group]
    PIP[Static Public IP]
    NIC[Network Interface]
    VM[Ubuntu Linux VM]

    VMID[VM Managed Identity]
    KV[Azure Key Vault]

    AMA[Azure Monitor Agent]
    DCR[Data Collection Rule]
    LAW[Log Analytics Workspace]
    ALERT[CPU Metric Alert]

    DEV --> GITHUB
    GITHUB --> ACTIONS
    ACTIONS --> OIDC
    OIDC --> DEPLOYID
    DEPLOYID --> TERRAFORM
    TERRAFORM <--> STATE

    TERRAFORM --> VNET
    VNET --> SUBNET
    SUBNET --> NSG
    SUBNET --> NIC
    PIP --> NIC
    NIC --> VM

    VM --> VMID
    VMID --> KV

    VM --> AMA
    AMA --> DCR
    DCR --> LAW
    VM --> ALERT
```

## Network Architecture

```text
Azure Virtual Network
10.10.0.0/16
│
└── Application Subnet
    10.10.1.0/24
    │
    ├── Network Security Group
    │   └── Restricted SSH access
    │
    └── Network Interface
        │
        ├── Private IP
        ├── Static Public IP
        │
        └── Ubuntu Linux VM
```

## CI/CD Authentication

```text
GitHub Actions
      │
      │ OpenID Connect
      ▼
GitHub OIDC Token
      │
      ▼
Azure Federated Credential
      │
      ▼
User-Assigned Managed Identity
      │
      │ Azure RBAC
      ▼
Azure Resources
```

No long-lived Azure client secret is stored in GitHub.

## VM Identity

The Ubuntu VM uses a separate system-assigned managed identity.

```text
Ubuntu VM
    │
    ▼
System-Assigned Managed Identity
    │
    │ Key Vault Secrets User
    ▼
Azure Key Vault
```

This provides identity-based access to Key Vault without embedding Azure credentials on the VM.

## Monitoring

```text
Ubuntu VM
    │
    ▼
Azure Monitor Agent
    │
    ▼
Data Collection Rule
    │
    ▼
Log Analytics Workspace
```

Azure Monitor also evaluates VM CPU utilization using a metric alert configured through Terraform.

## Terraform State

Terraform state is stored remotely in Azure Blob Storage.

```text
Developer Terraform ──┐
                      │
                      ▼
                Azure Blob State
                      ▲
                      │
GitHub Actions ───────┘
```

Remote state gives both local Terraform and GitHub Actions access to the same infrastructure state while keeping state files out of Git.