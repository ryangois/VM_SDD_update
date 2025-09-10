
# 💽 Azure VM Disk Checker

This repository provides a PowerShell-based solution to audit and report on OS and data disks attached to Azure Virtual Machines (VMs). It is designed for use in automated workflows via **GitHub Actions** or **Azure DevOps Pipelines**, and supports local testing.

---

## 🚀 Features

- Authenticates to Azure using a **Service Principal**
- Optionally iterates through **all subscriptions**
- Retrieves **OS and data disk** details for each VM
- Modular design using helper functions
- Robust **error handling** with `try/catch`
- Outputs disk type and name for **reporting or auditing**
- Supports `-DryRun` mode for safe simulations
- Optional **alerting via email or Microsoft Teams**

---

## 📁 Repository Structure

### `.github/workflows/azure-vm-disks.yml`
- **Purpose**: Defines the GitHub Actions workflow.
- **Triggers**:
  - `workflow_dispatch`: Manual execution from GitHub UI.
  - `cron`: Scheduled runs (e.g., daily at 03:00 UTC).
- **Function**: Executes the PowerShell script using `pwsh` on a Windows runner.

### `scripts/check-vm-disks.ps1`
- **Purpose**: Main PowerShell script.
- **Functionality**:
  - Authenticates to Azure.
  - Iterates over subscriptions and VMs.
  - Collects OS and data disk information.
  - Supports `-DryRun` mode.
  - Sends alerts if configured.

### `scripts/azure-pipeline.yml`
- **Purpose**: Azure DevOps pipeline definition.
- **Function**: Uses `AzurePowerShell@5` task to run the script.
- **Authentication**: Uses a pre-configured **Service Connection**.

### `check-vm-disks.ps1`
- **Purpose**: Standalone script for local testing.
- **Features**:
  - Accepts parameters like `-SubscriptionId`, `-ExportPath`, and `-DryRun`.
  - Useful for debugging before CI/CD integration.

### `Get-AzVmDiskInfo.psd1` & `Get-AzVmDiskInfo.psm1`
- **Purpose**: PowerShell module for modularity and reuse.
- **Functions**:
  - `Get-OsDiskInfo`: Retrieves OS disk details.
  - `Get-DataDiskInfo`: Retrieves data disk details.
  - `Export-DiskReport`: Exports results to CSV, JSON, or logs.
  - `Send-Alert`: Sends alerts via email or Teams.

### `run.ps1`
- **Purpose**: Local runner script for testing the module.
- **Functionality**:
  - Imports the module.
  - Calls disk info functions.
  - Saves logs or reports.
- **Use Case**: Ideal for validating logic before pushing to CI/CD.

---

## ⚙️ Usage

### GitHub Actions

1. Create a workflow file at `.github/workflows/azure-vm-disks.yml`.
2. Configure the following **repository secrets**:
   - `AZURE_CLIENT_ID`
   - `AZURE_SECRET`
   - `AZURE_TENANT_ID`

### Azure DevOps

1. Create a pipeline YAML file (`scripts/azure-pipeline.yml`).
2. Configure a **Service Connection** with appropriate permissions.

---

## 📊 Dashboard

You can integrate the exported CSV/JSON data into a dashboard using tools like:
- Power BI
- Grafana
- Azure Monitor Workbooks

---

## Requirements

- PowerShell **7+**
- **Az PowerShell Module** installed

---

## 📬 Alerts

To enable alerts:
- Configure email settings or Teams webhook in `Send-Alert` function.
- Use `-EnableAlerts` parameter in the script.

---

## 🧪 Dry Run Mode

Use `-DryRun` to simulate actions without making changes. Useful for testing and validation.

---

## 📄 License

MIT License
