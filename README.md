# FPGA Computer System - Project

## University of Belgrade, Faculty of Electrical Engineering

### Course: Computer Architecture and Digital Systems Design

Welcome to the repository for my FPGA Computer System project. This project is developed as part of the coursework at the University of Belgrade, Faculty of Electrical Engineering.

## Project Overview

This project involves developing a complete System on Chip (SoC) based on the picoComputer architecture. The primary focus is on the core functionalities of the hardware system, such as a custom FSM-based CPU, memory management, and various I/O communication protocols.

### Key Features:
- **Processor Design**: Implementation of a 16-bit CPU with a 3-address instruction format, featuring an FSM for instruction fetch, decode, and execution.
- **I/O Communication**: Development of controllers for PS/2 keyboard input and VGA monitor output with custom color-coded displays.
- **Peripheral Integration**: Implementation of supporting modules such as 7-segment display drivers, BCD converters, debouncers, and clock dividers.

## Installation

You can clone this repository to your local development environment. There's a makefile script included in the project that's used to compile and build it. You will need to have Altera Quartus II (v13.1) and ModelSim installed in order to be able to run the project. This includes tools for synthesis and simulation of the Verilog source files on a Cyclone III/V FPGA.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)
