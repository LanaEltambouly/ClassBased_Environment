# Verification Plan
# Synchronous Memory IP 16 x 32

## Introduction

This document defines the verification plan for the MEM\_16x32 synchronous memory IP. It captures the design intent from the block-level specification, the verification methodology, the exit criteria, the full set of test items and test cases, coverage goals, and the traceability between requirements and tests. It is intended to guide testbench development, review, and sign-off for this IP. 

## IP Design Details

MEM\_16x32 is a single-port synchronous memory containing 16 locations, each 32 bits wide, addressed by a 4-bit address. 

Every clock cycle is either a write if it’s enabled or a read if it’s not.

Reset is **asynchronous, active-low** as external pin and different clock domain

Valid\_out to validate the data\_out read from memory.

| Signal | Direction | Width | Description |
| :---- | :---- | :---- | :---- |
| CLK | input | 1 bit | System clock, positive-edge triggered  |
| Reset | input | 1 bit | Asynchronous, **active-low** reset  |
| Enable | input | 1 bit | 1 \= write cycle, 0 \= read cycle  |
| Address | input | log(16)  \= 4 bits  | Location of data in Mem |
| Data\_in | input | 32 bits | Write data |
| Data\_out | output | 32 bits | Read data |
| Valid | output | 1 bit | Valid read data  |

## Verification Strategy 

Self-checking, combining directed tests for the specific reset behavior with constrained-random regression. A reference model tracks the internal memory array's non-reset behavior, and predicts data\_out, valid\_out with the correct one-cycle registered latency.

## Test Case Table 

| TC\_ID | Description | Expected Result | Stimulus | Priority |
| :---- | :---- | :---- | :---- | :---- |
| TC\_01 | Reset the system | Data\_out \= 0, valid\_out \= 0 | Rst\_n \= 0  | High |
| TC\_02 | Write operation | mem\[address\] updated with data\_in; | enable \= 1, address \= random, data\_in \= random | High |
| TC\_03 | Read operation  | data\_out \= value stored at address, valid\_out \= 1 after one cycle later | enable \= 0, address \= random | High |
| TC\_04 | valid\_out timing  | valid\_out \= \~enable delayed by one clock cycle  | enable toggled 0→1→0→1  | High |
| TC\_05 | Address boundaries | Correct write/read at address 0x0 and 0xF | enable \= 1 then 0, address \= 0x0, then address \= 0xF | Medium |
| TC\_06 | All-address sweep | All 16 locations read back correctly after being written | enable \= 1 for 16 cycles (unique randomized data per address), then enable \= 0 for 16 reads   | Medium |

## 

## Traceability Matrix 

| TC\_ID | Enable | Reset | valid\_out |
| :---- | ----- | ----- | :---- |
| TC\_01 |  | yes |  |
| TC\_02 | yes | yes |  |
| TC\_03 | yes | yes | yes |
| TC\_04 | yes | yes | yes |
| TC\_05 | yes | yes | yes |
| TC\_06 | yes | yes | yes |

## Exit Criteria 

* All test cases executed and passed on QuestaSim.  
* Code coverage 100% on simulator  
* Functional coverage for all ports and internal signals  
* No linting issues 

## Coverage results

## Opened issues

## Feature Assessment 

