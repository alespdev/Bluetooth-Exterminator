# 💀 BLUETOOTH EXTERMINATOR V3.1
> **Advanced Bluetooth Auditing & Stress Testing Suite** > *Desarrollado por: alespdev*

---

## 📖 Descripción
**Bluetooth Exterminator** es una potente suite de herramientas escrita en Bash para sistemas Linux. Utiliza el stack de **BlueZ** para realizar pruebas de estrés, auditoría de protocolos y saturación de radiofrecuencia en dispositivos Bluetooth. 

**Se recomienda usar adaptador BT externo.**
---

## ⚡ Métodos de Ataque

| Método | Descripción Técnica | Impacto Esperado |
| :--- | :--- | :--- |
| **Broadcast Jamming** | Envía comandos de inundación HCI y ráfagas l2ping al espectro global (`00:00:00...`). | Saturación del canal de radio y desconexión de dispositivos cercanos. |
| **Targeted Jamming** | Ataque dirigido mediante inundación de paquetes L2CAP de gran tamaño (640 bytes) a una MAC específica. | Congelamiento de servicios y lag en el dispositivo objetivo. |
| **GATT/SDP Stress** | Genera identidades aleatorias para solicitar repetidamente el Service Discovery Protocol (SDP). | Saturación del procesador del dispositivo Bluetooth al intentar enumerar servicios inexistentes. |

---

## 🛠️ Requisitos del Sistema

El script requiere que el sistema tenga instalado el paquete `bluez-utils` y las herramientas nativas de Bluetooth.

### Dependencias:
- **BlueZ Stack:** `hcitool`, `hciconfig`, `l2ping`, `sdptool`.
- **Privilegios:** Root (sudo) obligatorio para la manipulación de interfaces HCI.
- **Terminal:** Compatible con secuencias de escape ANSI (Zorin OS, Ubuntu, Kali, Parrot, etc.).

```bash
# 1. Instalación de dependencias
sudo apt update && sudo apt install bluez bluez-tools -y

# 2. Configuración de permisos de ejecución
chmod +x exterminator.sh

# 3. Ejecución de la suite
sudo ./exterminator.sh
