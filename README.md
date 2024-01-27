# RISC-V-Implementation

This repository hosts the design and implementation of a RISC-V processor in two forms: a fully functional single-cycle implementation and a partially completed pipelined implementation. The focus of this project is to demonstrate the basic principles of RISC-V architecture and processor design. This project has ideas carried on from the [CPEN-211-Labs](https://github.com/sidharthsudhir-03/CPEN-211-Labs) repository.

## Features

Single-Cycle Implementation:
* Fully functional and tested.
* Implements 6 basic RISC-V instructions and 7 branch instructions.
* Constrained to operate at a clock speed of approximately 109 MHz.
  
Pipelined Implementation (Partial):
* Attempted implementation, not fully functional.
* Includes a branch control unit with a finite state machine (FSM) to detect branch decisions.
* Capable of a one-cycle delay on taken branches, otherwise operates without delay.

.The code was developed and synthesized in Quartus and simulated in ModelSim.
