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

TARGETS:

bash```
       help            - Show the help (this text).
       
       simul_all       - Compile and simulate the design (Shell-based).
       simul_lib       - Create the work library.
       simul_cmp       - Compile the design.
       simul_run       - Start default simulation (shell-based).
       simul_run_gui   - Start GUI-based simulation.
       simul_run_sh    - Start shell-based simulation.
       simul_wave_old  - Show already existing wave (do not run simulation).
       simul_wave_new  - Show newly created wave (run simulation).
       simul_clean     - Clean simulation directory.
       
       synth_all       - Analyze & Synthesize, Place & Route, Assembly and Static Time Analyze.
       synth_map       - Map (Analyze & Synthesize).
       synth_fit       - Fit (Place & Route).
       synth_asm       - Assemble.
       synth_sta       - Static Time Analyze.
       synth_net       - Create post-fit netlist.
       synth_pgm       - Program the device.
       synth_clean     - Clean synthesis directory.
       
       list_all        - Create list for Icarus Verilog, simulation and synthesis
       list_icarus     - Create list of Icarus Verilog library directories
       list_simul      - Create list of simulation source files (src/*)
       list_synth      - Create list of synthesis source files (src/synthesis/*)
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
