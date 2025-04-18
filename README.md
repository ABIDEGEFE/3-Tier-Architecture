
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

"C:\Users\SolNet\Downloads\step1Github.png"
