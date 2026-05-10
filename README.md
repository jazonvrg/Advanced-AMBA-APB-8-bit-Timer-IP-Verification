# 🚀 Advanced SystemVerilog Verification: APB-Based 8-Bit Timer IP

An advanced, coverage-driven verification environment built entirely from scratch using **SystemVerilog**. Unlike my previous projects focused on RTL design, this project focuses exclusively on the **Design Verification (DV)** phase. Operating on a provided RTL black-box, my main focus was on architecting a robust, Object-Oriented (OOP) testbench featuring virtual interfaces, mailboxes, and automated scoreboards to validate a dual-clock domain APB slave IP.

### 📦 Technologies & Methodologies

* **Verification Language:** SystemVerilog (OOP, IPC, Virtual Interfaces, Randomization)
* **Protocol:** AMBA APB (Advanced Peripheral Bus)
* **Architecture:** Layered Testbench, Coverage-Driven Verification (CDV), Handshake Synchronization
* **Tools:** QuestaSim / ModelSim, Linux, VIM
* **Artifacts:** Verification Plan (VPLAN), Functional Coverage (Covergroups), Directed & Random Testcases

### ⚙️ DUT Features (The Target)

The Design Under Test (DUT) is an 8-bit Timer IP acting as an APB slave. It was verified against the following specifications:
* **Protocol Compliance:** Supports standard APB transfers with no wait states and no error handling.
* **Dual Clock Domains:** Operates across two distinct clock domains: `pclk` (50 MHz) for register configuration and `ker_clk` (200 MHz) for the internal timer ticking.
* **Core Functions:** Supports both count up and count down modes. Features programmable initial load values.
* **Clock Divisor:** The core clock can be dynamically divided by 2, 4, or 8 via register configuration.
* **Interrupt Generation:** Detects overflow (count reaches 255) and underflow (count reaches 0) conditions, supporting both polling and interrupt-driven operations.

### 📐 Hardware Specifications (Spec)

**1. Input/Output Ports:**

| Port Name | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `ker_clk` | Input | 1-bit | Timer core clock (200 MHz). |
| `pclk` | Input | 1-bit | APB bus clock (50 MHz). |
| `presetn` | Input | 1-bit | Active-low system reset. |
| `paddr`, `psel`, `penable`, `pwrite` | Input | Various | Standard APB control and address signals. |
| `pwdata` | Input | 8-bit | APB write data bus. |
| `prdata` | Output | 8-bit | APB read data bus. |
| `pready` | Output | 1-bit | APB ready signal. |
| `interrupt` | Output | 1-bit | Triggered on overflow/underflow. |

**2. Register Map:**
* **`0x00` - TCR:** Timer Configuration Register (Clock divisor, Load, Count direction, Enable).
* **`0x01` - TSR:** Timer Status Register (Overflow/Underflow flags, R/W1C).
* **`0x02` - TDR:** Timer Data Register (Data load value).
* **`0x03` - TIE:** Timer Interrupt Enable Register.

**3. Module Descriptions (Testbench Components):**

To thoroughly verify the DUT, I implemented a layered OOP testbench structure:
* **`dut_interface` (Virtual Interface):** Bundles the physical APB signals. Virtual interfaces are passed to the class-based environment to drive and sample pins dynamically without hardcoding hierarchical paths.
* **`packet` (Transaction Class):** An OOP class defining the data structure for a single APB transfer (Address, Data, Command).
* **`stimulus` (Generator):** Creates `packet` objects (test scenarios) and sends them to the Driver via a SystemVerilog Mailbox.
* **`driver`:** Receives packets from the mailbox and wiggles the physical APB pins via the Virtual Interface. It triggers an `event` (`xfer_done`) to synchronize with the main test.
* **`monitor`:** Passively observes the APB bus. Upon detecting a valid transaction, it packs the sampled data into a `packet` and sends it to the Scoreboard via a mailbox.
* **`scoreboard`:** The central checking mechanism. It compares actual DUT responses against an expected Golden Model and utilizes embedded `covergroup` definitions to measure Functional Coverage.

### 📁 Project Structure

    Advanced-AMBA-APB-8-bit-Timer-IP-Verification/
    ├── rtl/                        # Design Under Test (Black-box IP)
    │   ├── timer_clock_divisor.vp  # Protected RTL: Clock divider logic
    │   ├── timer_counter.vp        # Protected RTL: Core counting logic
    │   ├── timer_interrupt.vp      # Protected RTL: Interrupt generation
    │   ├── timer_register.vp       # Protected RTL: APB Register mapping
    │   └── timer_top.v             # Top-level DUT wrapper
    ├── tb/                         # Verification Environment (SV Classes)
    │   ├── timer_pkg.sv            # Package containing all class definitions
    │   ├── dut_interface.sv        # Physical APB interface
    │   ├── packet.sv               # Transaction item class
    │   ├── stimulus.sv             # Scenario generator
    │   ├── driver.sv               # APB bus driver
    │   ├── monitor.sv              # APB bus monitor
    │   ├── scoreboard.sv           # Golden model checker & covergroups
    │   ├── environment.sv          # Wrapper grouping Driver, Monitor, Scoreboard
    │   └── testbench.sv            # Top module: Clock gen & instantiation
    ├── testcase/                   # Test Library (Directed & Random Scenarios)
    │   ├── test_pkg.sv             # Package for testcases
    │   ├── base_test.sv            # Base class with R/W tasks & handshake
    │   ├── reset_test.sv, rsv_test.sv, default_value_register_test.sv
    │   ├── tcr_test.sv, tdr_test.sv, tie_test.sv, tsr_test.sv 
    │   ├── count_up_test.sv, count_down_test.sv, timer_enable_test.sv
    │   ├── divide_2_test.sv, divide_4_test.sv, divide_8_test.sv, no_divide_test.sv
    │   └── overflow_test.sv, underflow_test.sv, load_test.sv
    └── sim/                        # Simulation Workspace
        └── Makefile                # Automation for compilation and regression

### 🦉 The Process

Transitioning to Advanced DV required adopting a software-engineering mindset for hardware testing. I treated the RTL entirely as a black-box.
1.  **VPLAN Extraction:** I started by analyzing the specifications to extract features, creating a Verification Plan mapping every register bit and functional behavior to a specific testcase.
2.  **Environment Construction:** I built the SV framework, utilizing Mailboxes for Inter-Process Communication (IPC) and Events (`-> xfer_done`) to synchronize the Stimulus generation with the Driver's physical execution.
3.  **Test Library Development:** I wrote 19 distinct testcases (as seen in the `testcase` directory). This included register access tests, functional tests (e.g., `count_up_test.sv`, `divide_4_test.sv`), and boundary edge-case tests (e.g., `overflow_test.sv`).
4.  **Coverage & Automation:** I utilized a `Makefile` to run automated regressions. The embedded `covergroup` in the Scoreboard ensured that all features (like clock division ratios and interrupt triggers) were mathematically proven to be exercised.

### 📚 What I Learned

* **Object-Oriented Programming (OOP) in SV:** Mastered the use of classes, inheritance, and object instantiation to build a scalable and modular testbench.
* **Inter-Process Communication (IPC):** Learned to securely pass data between parallel running blocks using `mailbox` and synchronize procedural threads using SystemVerilog `event`.
* **Cross-Clock Domain Awareness:** Gained practical experience verifying IPs that operate on multiple asynchronous clocks (`pclk` vs `ker_clk`).

### 📋 Verification Plan (VPLAN) Summary

| Item | Sub Item | Testcase File | Pass Condition | Result |
| :--- | :--- | :--- | :--- | :--- |
| **Register Access** | Reset Default Values | `default_value_register_test.sv` | Reading registers post-reset matches spec exactly. | ✅ PASS |
| **Clock Logic** | Divisor Validation | `divide_4_test.sv`, `divide_8_test.sv` | Timer core increments at exactly the divided clock rate. | ✅ PASS |
| **Counting Mode** | Up/Down Selection | `count_up_test.sv`, `count_down_test.sv` | Counter increments or decrements accurately per clock tick. | ✅ PASS |
| **Boundary Logic** | Overflow/Underflow | `overflow_test.sv`, `underflow_test.sv` | Interrupt flag asserts correctly when boundaries (255 or 0) are crossed. | ✅ PASS |

### 📊 Verification Results & Artifacts

1. **Simulation Regression Log**
<p align="center">
  <img src=" KÉO THẢ ẢNH LOG VÀO ĐÂY " alt="Terminal Log">
</p>

2. **Code & Functional Coverage Report (100%)**
<p align="center">
  <img src=" KÉO THẢ ẢNH COVERAGE VÀO ĐÂY " alt="Coverage Report">
</p>

### 💭 How can it be improved?

* **Migrate to UVM:** Upgrade this raw SystemVerilog testbench into a full Universal Verification Methodology (UVM) environment, utilizing Sequences, Sequencers, and the UVM Factory for better reusability.
* **SystemVerilog Assertions (SVA):** Bind concurrent assertions directly to the DUT interface to constantly monitor APB protocol compliance.
