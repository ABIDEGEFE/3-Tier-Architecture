
# **Step 1: Virtual Network & Subnet Configuration**  

## **Objective**  
Configure a secure Azure Virtual Network (VNet) with isolated subnets for frontend and backend tiers, enforcing strict traffic rules via Network Security Groups (NSGs).

---

## **Implementation (Azure Portal Steps)**
you can use the above bash scripting code to create virtual network, subnet and storage account.

### **1. Create Virtual Network**
1. Navigate to **Virtual Networks** in Azure Portal  
2. Click **+ Create**  
3. Enter:  
   - **Name**: `contosoBoutiqueVNet`  
   - **Address space**: `10.0.0.0/16`  
   - **Subscription/Resource Group**: Select your resources  
   - **Region**: Choose your deployment region  

### **2. Create Subnets**
Under the newly created VNet:  
#### **Frontend Subnet (`frontEndSubnet`)**  
- **Subnet name**: `frontEndSubnet`  
- **Address range**: `10.0.1.0/24`  

#### **Backend Subnet (`backEndSubnet`)**  
- **Subnet name**: `backEndSubnet`  
- **Address range**: `10.0.2.0/24`  

---

## **Security Configuration**

### **Frontend NSG (`nsg-frontend`)**
1. Create a new Network Security Group:  
   - **Name**: `nsg-frontend`  
   - **Inbound Rules**:  
     - Allow HTTP (Port 80) from `Any` source  
     - Allow HTTPS (Port 443) from `Any` source  
   - All other inbound traffic: **Deny by default**

2. Associate NSG to `frontEndSubnet`.

### **Backend NSG (`nsg-backend`)**
1. Create a new Network Security Group:  
   - **Name**: `nsg-backend`  
   - **Inbound Rules**:  
     - Allow TCP (Port 3000) from source `10.0.1.0/24` (frontend subnet)  
   - All other inbound traffic: **Deny by default**

2. Associate NSG to `backEndSubnet`.

---

## **Validation**  
Verify:  
1. Each subnet shows the correct NSG association  
2. No public IPs are assigned to backend resources  
3. Frontend subnet only shows allowed HTTP/HTTPS rules  

---

## **Key Security Principles**  
- 🔒 **Zero Trust Architecture**: Backend inaccessible from internet  
- 🌐 **Tier Isolation**: Subnets restrict lateral movement  
- 🛡️ **Defense in Depth**: NSGs enforce minimal required access  

DIAGRAMATICAL REPRESENTATION

![step1Github](https://github.com/user-attachments/assets/ce56014d-bd17-4654-a2b3-2d9011c6d6d6)


# **Step 2: Deploy VM Scale Sets & Load Balancers**  

## **Objective**  
Deploy scalable virtual machine clusters for frontend (IIS) and backend (Node.js) tiers with appropriate load balancing and high availability configurations.

---

## **Implementation (Azure Portal Steps)**

### **1. Frontend Tier (Presentation Layer)**
#### **VM Scale Set Configuration**
1. Create a new **Virtual Machine Scale Set**:
   - **Name**: `vmss-frontend`
   - **OS**: Windows Server 2019 Datacenter
   - **Instance size**: Standard_B2s (or your preferred tier)
   - **Instance count**: 2-4 (enable autoscaling later)
   - **Virtual network**: `app_vnet`
   - **Subnet**: `frontEndSubnet`

2. **Load Balancer Setup** (Public-facing):
   - Create new **Standard SKU** load balancer
   - **Frontend IP**: Public IP address
   - **Backend pool**: Select `vmss-frontend` instances
   - **Health probe**: HTTP on port 80
   - **Load balancing rule**: 
     - Protocol: TCP
     - Port: 80 (HTTP) and 443 (HTTPS)
     - Session persistence: None

3. **IIS Installation** (via Custom Script Extension):
   ```powershell
   Install-WindowsFeature -name Web-Server -IncludeManagementTools
   ```

### **2. Backend Tier (Application Layer)**
#### **VM Scale Set Configuration**
1. Create a new **Virtual Machine Scale Set**:
   - **Name**: `vmss-backend`
   - **OS**: Ubuntu 20.04 LTS
   - **Instance size**: Standard_B2s
   - **Instance count**: 2
   - **Virtual network**: `app_vnet`
   - **Subnet**: `backEndSubnet`

2. **Internal Load Balancer**:
   - Create new **Standard SKU** internal load balancer
   - **Frontend IP**: Private IP (e.g., 10.0.2.5)
   - **Backend pool**: Select `vmss-backend` instances
   - **Health probe**: TCP on port 3000
   - **Load balancing rule**:
     - Protocol: TCP
     - Port: 3000
     - Allow floating IP: No

3. **Node.js Deployment** (via Custom Script):
   ```bash
   #!/bin/bash
   sudo apt update
   sudo apt install -y nodejs npm
   npm init -y
   npm install express cors
   ```

---

## **Configuration Details**

| Component | Frontend Tier | Backend Tier |
|-----------|--------------|--------------|
| **VM Image** | Windows Server 2019 | Ubuntu 20.04 LTS |
| **Scale Set Name** | vmss-frontend | vmss-backend |
| **Load Balancer Type** | Public | Internal |
| **Allowed Ports** | 80, 443 | 3000 (from frontend only) |
| **Health Probe** | HTTP:80 | TCP:3000 |
| **Autoscaling** | CPU > 80% | CPU > 8% |

---

## **Validation Steps**
1. **Frontend Test**:
   - Access the public IP in browser → Should display the first page
   - Verify load balancer health probes show "Healthy"

2. **Backend Test**:
   - SSH into a frontend VM
   - Run `curl http://10.0.2.5:3000/api/image` → Should return image data from storage
   - Confirm NSG blocks direct internet access to backend

---

## **Key Architecture Principles**
- 🚀 **Horizontal Scaling**: VMSS allows dynamic instance adjustment
- 🔒 **Security Isolation**: Backend only accessible via internal LB
- ⚖️ **Traffic Distribution**: LB ensures even workload spread
- 🩺 **Health Monitoring**: Probes automatically remove unhealthy instances

DIAGRAMATICAL REPRESENTATION

![step2Github](https://github.com/user-attachments/assets/13a59151-002c-4719-94fc-83a42c09559a)


# **Step 3: Secure Blob Storage Configuration**  

## **Objective**  
Create a private, geo-redundant Azure Blob Storage account for product images, accessible only by the backend tier via Private Endpoint.

---

## **Implementation (Azure Portal Steps)**

### **1. Create Storage Account**
// you can use the above bash script code to create storage account
1. Navigate to **Storage Accounts** → **+ Create**
2. Basic Configuration:
   - **Name**: `storage665506` // you can use different name based on your project, but must be unique.
   - **Performance**: Standard
   - **Redundancy**: **Geo-redundant storage (GRS)**  
     *(Maintains 6 copies across paired regions for disaster recovery)*
   - **Public access**: **Disabled** (default)

3. Advanced Security:
   - Enable **Storage account key rotation**
   - Disable **Blob public access**
   - Enable **Infrastructure encryption**

### **2. Configure Private Endpoint**
1. In your storage account → **Networking** → **Private Endpoint Connections**
2. **+ Private Endpoint**:
   - **Name**: `pe-contosoproducts-blob`
   - **Virtual Network**: `app_vnet`
   - **Subnet**: `backEndSubnet`
   - **Target sub-resource**: `blob`
   - **Private DNS Integration**: Enable (creates `privatelink.blob.core.windows.net`)

### **3. Create Blob Container**
1. Go to **Containers** → **+ Container**
   - **Name**: `image`
   - **Public access level**: Private

---

## **Security Validation**
**Public Access Test** (should fail):
   ```bash
   curl -I https://contosoproducts.blob.core.windows.net/product-images/
   # Expected: 403 Forbidden
   ```

---

## **High Availability Configuration**
| Setting | Value | Purpose |
|---------|-------|---------|
| **Redundancy** | GRS | 99.999999999% (11 nines) durability |
| **Failover** | Manual cross-region failover | Controlled disaster recovery |
| **Access Tier** | Hot | Optimized for frequent reads |
| **Lifecycle Policy** | Move to Cool after 30 days | Cost optimization |

---

## **Key Architecture Benefits**
- 🔒 **Zero Public Exposure**: All access routed through VNet Private Endpoint
- 🌍 **Geo-Resilience**: GRS maintains copies in paired Azure regions
- ⚡ **Low-Latency Access**: Backend VMs connect via Azure backbone network
- 📊 **Scalable Storage**: Automatically scales with product catalog growth

---

---

DIAGRMATICAL REPRESENTATION

![step3Github](https://github.com/user-attachments/assets/9d451f52-f2cf-4e5e-ada7-101f21805478)



