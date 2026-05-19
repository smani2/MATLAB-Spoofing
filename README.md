# PCG-CWDE Cross-Layer Authentication Framework



## Overview
This repository contains the MATLAB implementation of:

"Adaptive Confidence-Based Cross-Layer Authentication 
Under Co-Located Attacks"

Sanjay Mani, Prof. Moh Khalid Hasan, Prof. Min Song
Stevens Institute of Technology

## Dataset
**CSI_data.mat is too large for GitHub.
Download it here:
https://drive.google.com/file/d/1liYlOxwPVNAf_a0a_vz8ARfqoaQUJGXg/view?usp=sharing**

After downloading place CSI_data.mat in the 
same folder as main.m

Dataset source:
Kong, R. and Chen, H., "CSI-RFF: Leveraging 
Micro-Signals on CSI for RF Fingerprinting of 
Commodity WiFi," IEEE Transactions on Information 
Forensics and Security, vol. 19, pp. 5301-5315, 2024.

## Repository Structure
- main.m                → Run this first
- llll.m                → Feature extraction
- all15dvcscsirff.m     → Figure 1: All 15 devices
- dvc1and2comp.m        → Figure 2: Device 1 vs 2

## How To Run
1. Download this repository
2. Download CSI_data.mat from link above
3. Place CSI_data.mat in same folder as main.m
4. Open MATLAB
5. Navigate to project folder
6. Run main.m

## Figures

### Figure 1 — All 15 Devices CSI and RF Fingerprint
![Figure 1](Fig1_All15Devices.png)

### Figure 2 — Device 1 vs Device 2 Comparison
![Figure 2](Fig2_Device1vs2.png)

## Requirements
- MATLAB R2020a or later
- Statistics and Machine Learning Toolbox
