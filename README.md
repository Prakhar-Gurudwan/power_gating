IMPLEMENTATION OF POWER GATING TECHNIQUE
FOR PROCESSOR FUNCTIONAL UNITS



The main goal of this project is to design and implement an energy-efficient digital system that minimizes unnecessary power consumption without affecting performance, the project focuses on applying power gating techniques to different parts of a simple processor architecture. 

RTL SCHEMATIC 
<img width="1883" height="982" alt="image" src="https://github.com/user-attachments/assets/0739dce7-2bbc-44bc-be5e-50a26b56d252" />
DEATILED MODULE DESCRIPTION

1.ALU Module

the module has input ports for the clock signal, reset signal, two four-bit operands called A and B, and a three-bit opcode. The outputs include the four-bit result, the idle detection flag, the power-gated status flag, and the gated clock signal.

2.MEMORY Module

The memory is declared as a two-dimensional array with sixteen rows and eight columns, effectively creating sixteen eight-bit storage locations.
Activity detection here is more complex because we need to track four signals: the address, data input, write enable, and request valid flag

3.IO CONTROLLER

The IO Controller is the simplest of the three. It has an internal retained_out register that stores written data. Activity is detected when there's a write enable signal, a read request, or when the input data changes.

4.POWER MANAGEMENT CONTROLLER

The Power Management Controller receives idle detection signals and power-gated status signals from all three components.

The controller maintains several counters. The total_cycles counter tracks how many clock cycles have elapsed since reset. The gated_cycles counter specifically tracks cycles where all three components are simultaneously power-gated.

TESTING AND VALIDATION

 DEVELOPED 6 TEST CASES TO CHECK POWER SAVINGS USING THIS  PROJECT

 TEST CASE -1:
 
 Continuous ALU Activity
 
In this test, we generate 30 consecutive ALU operations with changing inputs every clock cycle. The expectation is that the ALU remains fully active for all thirty-one cycles (thirty operations plus one overhead). Meanwhile, since we never touch Memory or IO, those components should detect idle conditions within five cycles, implement clock gating at seven cycles, and power-gate completely by nine cycles. 

<img width="946" height="1093" alt="image" src="https://github.com/user-attachments/assets/0005894c-d5f2-4961-88d8-f14887fcc7b6" />


TEST CASE -2 :

Burst Activity with Idle Periods

This test simulates a more realistic workload where computation happens in bursts separated by idle periods. We perform five ALU operations, then wait for ten cycles, perform five more ALU operations, then wait for fifteen cycles.

<img width="878" height="1114" alt="image" src="https://github.com/user-attachments/assets/4122b213-b1e8-404d-8c56-8217d0b8ac3b" />


TEST CASE -3 : 

Memory-Intensive Workload

we perform ten memory write operations, wait through an idle period, then perform ten memory read operations, followed by a long idle period. The pattern is similar to Test Case Two but focuses on Memory while leaving ALU and IO power-gated throughout.

<img width="852" height="1085" alt="image" src="https://github.com/user-attachments/assets/5c8c64e6-7ba7-4178-8bb2-e94c46707ae7" />



TEST CASE -4: 

IO-Intensive Operations

This test exercises the IO Controller with write bursts and read bursts while keeping ALU and Memory mostly idle.

<img width="1080" height="1125" alt="image" src="https://github.com/user-attachments/assets/446f6291-9aa3-443e-b9ed-301c74c8fd8a" />



TEST CASE -5:

Mixed Workload

We activate each component in sequence: first ALU, then Memory, then IO, then all go idle. This simulates a complete computational task that requires all system resources.

<img width="1042" height="1101" alt="image" src="https://github.com/user-attachments/assets/962612fc-1c70-4ed9-981f-296cdcd1e328" />



TEST CASE -6: 

Realistic Processor Simulation

This test simulates a typical instruction execution cycle. For each instruction, we fetch from Memory (read operation), execute using the ALU (computation), and write back to Memory (write operation). We repeat this pattern multiple times with idle periods representing pipeline bubbles or waiting for external events.

<img width="658" height="1075" alt="image" src="https://github.com/user-attachments/assets/fdd48e11-288e-4b98-9e04-1bbdca22360f" />


OVERALL SUMMARY 
<img width="1026" height="886" alt="image" src="https://github.com/user-attachments/assets/12ec2c90-8e2c-49ad-a1d2-f1738dc716e5" />
<img width="818" height="474" alt="image" src="https://github.com/user-attachments/assets/55d7c558-fab2-4a60-8492-c2b7d5eb67e5" />





