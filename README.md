# FPGA Computer System - picoComputer SoC

## University of Belgrade, Faculty of Electrical Engineering

### Course: Computer Architecture / Digital Systems Design

Welcome to the repository for my FPGA-based computer system project. This project is developed as part of the coursework at the University of Belgrade, Faculty of Electrical Engineering, focusing on the implementation of a custom 16-bit processor and its supporting ecosystem.

## Project Overview

This project involves developing a complete System on Chip (SoC) based on the **picoComputer** architecture. It features an FSM-based CPU with a three-address instruction format, integrated memory, and a variety of I/O controllers for interacting with real-world hardware like PS/2 keyboards and VGA monitors.

### Key Features:
- **Custom 16-bit CPU**: A Finite State Machine (FSM) implementation supporting arithmetic, logic, and control flow instructions.
- **Memory Subsystem**: Parameterized memory module with 64 addressable locations.
- **PS/2 & VGA Controllers**: Full support for keyboard input decoding and video signal generation.
- **Automated Workflow**: Entire build process is managed via Makefile, supporting both Altera Quartus (for synthesis) and ModelSim (for simulation).

## Project Structure

The project is organized into several key directories:
- **`src/`**: Contains all Verilog source files (CPU, ALU, peripherals).
- **`tooling/`**: Contains the build system and configuration files.
- **`config/`**: TCL scripts and waveform definitions for ModelSim.

## Development Workflow

The project uses a **Makefile-driven** workflow, allowing for easy simulation and hardware synthesis from the command line (or VS Code terminal).

### Prerequisites
- **Altera Quartus II (v13.1)** for synthesis.
- **ModelSim / Questa SIM** for simulation.
- **Cygwin/Bash** environment for executing the Makefile.

### Simulation Commands
To compile the design and run the simulation in ModelSim:
```bash
# Run simulation in shell mode
make simul_run_sh

# Run simulation and open ModelSim GUI with waveforms
make simul_run_gui

# Clean simulation files
make simul_clean

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
