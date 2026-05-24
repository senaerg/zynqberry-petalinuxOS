
# ZynqBerry Embedded PetaLinux OS

A step-by-step repository for running an embedded PetaLinux (v2018.2) distribution on the Trenz Electronic **ZynqBerry** (TE0726 series) FPGA development board. 

Because the ZynqBerry routes its 4x USB 2.0 ports and Ethernet port through an SMSC LAN9514 controller via a ULPI-PHY transceiver rather than connecting them directly to the Zynq-7010 SoC, bare-metal drivers are highly complex. This project utilizes Embedded Linux to natively leverage Xilinx's pre-built ULPI and LAN95XX drivers.

## 🛠 Prerequisites & Environment
* **Hardware:** Trenz Electronic ZynqBerry (Zynq 7010 CLG225 package), Micro-USB JTAG/UART cable, MicroSD Card (min 4GB).
* **OS:** Ubuntu 16.04 LTS
* **Tools:** Xilinx Vivado / SDK / PetaLinux v2018.2

---

## 🚀 Step-by-Step Implementation

### 1. Project Initialization & Hardware Import
Change directories into your working project folder, initialize the PetaLinux structure, and import your hardware configuration file (`.hdf`):

```bash
petalinux-create --type project --template zynq --name zynqberryOS
cd zynqberryOS
petalinux-config --get-hw-description=/path/to/hardware/directory/
