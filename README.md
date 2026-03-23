# Sao Nexus

Sao Nexus is a comprehensive, modular cybersecurity and system auditing framework built natively in Bash. Designed to operate efficiently across POSIX-compliant environments, it provides security researchers, penetration testers, and system administrators with a unified terminal interface containing 25 specialized utilities for reconnaissance, network analysis, vulnerability scanning, and cryptographic operations.

Developed and maintained by [sao2139](https://github.com/sao2139).

## Architecture Overview

The framework is strictly structured into specialized core modules to ensure maintainability and high performance without relying on heavy external runtime environments:

- `main.sh`: The core execution engine handling the interactive menus and routing.
- `core/visuals.sh`: Manages the terminal user interface, dynamic rendering, and the boot sequence.
- `core/logic.sh`: Contains system profiling, permission auditing, and local network analysis tools.
- `core/osint.sh`: Passive intelligence gathering routines (DNS, geolocation, header auditing).
- `core/web_auditor.sh`: Offensive and defensive web assessment tools.
- `core/crypto.sh`: Cryptographic functions and secure key generation.
- `core/deps.sh`: Handles early-stage dependency validation and the forensic logging engine.

## Features

Sao Nexus implements 25 operational tools grouped into 5 tactical categories:

### [SYS] System and Process Management
- Basic OS Information Gathering (uname implementation).
- Advanced Hardware Profiler (CPU architecture, RAM allocation, Logical storage).
- Tactical Process Manager (View memory consumption and terminate processes by PID).
- Insecure Permissions Auditor (Identify global 777 modifiers and SUID misconfigurations).
- Local Backdoor Scanner (Detect unknown listeners on common malicious ports).
- DNS Hosts File Auditor (Check for static DNS hijacking).

### [NET] Network and Connectivity
- Stealth TCP Port Scanner.
- Local Network Topology Analyzer (ARP cache dumping).
- Physical Network Interface Profiler.
- Network Hop Tracker (Traceroute implementation).
- Vectorial Subnet Calculator (CIDR processing).
- Active Connections Monitor.

### [ATK] Web Auditing and Forensics 
- Passive Web Directory Scanner.
- Basic Reflected XSS Prober.
- Error-Based SQL Injection Prober.
- HTTP Methods Enumerator (Detects insecure PUT/DELETE/TRACE verbs).
- Local HTTP Load Tester (Synthetic stress testing).
- Forensic Metadata Extractor (Target files).

### [OSI] OSINT and Intelligence
- Passive Subdomain Enumerator (Via crt.sh transparency logs).
- Domain and DNS Intelligence Reconnaissance.
- Advanced IP Geolocation Tracking.
- SSL/HTTP Security Header Auditor.
- Passive Remote Banner Grabbing.
- Covert Web Scraper (Extracts embedded emails and hyperlinks).

### [SEC] Cryptography and Security
- ED25519 Asymmetric SSH Keypair Generator.
- High-Entropy Password Generator.
- Integrity Hash Calculator (MD5/SHA256).
- Base64 Encoding/Decoding Utility.

## Advanced Capabilities

- **Dependency Check Subsystem:** During initialization, the framework aggressively verifies the presence of required environmental binaries (curl, openssl, netstat, awk, ssh-keygen, nslookup) allowing the framework to fail gracefully.
- **Forensic Reporting Engine:** Features an optional session logger. When activated, all successful extractions, discovered vulnerabilities, and critical system alerts are automatically stripped of ANSI color codes and appended with timestamps to a secure log file within the `logs/` directory.
- **Resiliency:** Graceful SIGINT handling ensures safe termination, memory clearing, and terminal restoration upon unexpected exits.

## Installation

Clone the repository and ensure execution permissions are granted to the main entry point:

```bash
git clone https://github.com/sao2139/sao_nexus.git
cd sao_nexus
chmod +x main.sh
```

## Usage

Execute the framework via bash. Administrative privileges (root/sudo) may be required for specific tools such as the SUID permissions auditor to function at full capacity.

```bash
bash main.sh
```

## Disclaimer

This framework was developed exclusively for educational purposes and authorized security auditing. The developer assumes no liability and is not responsible for any misuse, damage, or illegal activities conducted with these tools. 
