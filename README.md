# 📟 FPGA Hardware UART Driver 

An HDL-based, high-performance **Universal Asynchronous Receiver-Transmitter (UART)** controller framework compiled for FPGA architectures. The driver core incorporates an internal baud-rate generator, receiver/transmitter modules, and dual hardware FIFO circular queues to facilitate robust full-duplex serial communication between an FPGA fabric and host computing layers.

This project demonstrates synchronous digital logic design, circular buffer handling (FIFOs), and physical layer hardware description modeling.

---

## ✨ Features

* ⚡ **Full-Duplex Telemetry:** Independent RX and TX processing engines enabling simultaneous bi-directional bitstream transmission.
* ⏱️ **Configurable Baud Engine:** A fractional clock divider/tick generator mapping system oscillators to target communication frequencies.
* 📦 **Deep FIFO Buffering:** Dual independent First-In, First-Out memory arrays safeguarding data integrity against overrun exceptions.
* 🛠️ **Mimas V2 Ready:** Out-of-the-box pinout constraint mappings prepared specifically for the Spartan-6 based Mimas V2 development board.
* 🔬 **Fully Simu-Ready:** Includes a verified testbench infrastructure validated via ISim simulation waveform analysis engines.

---

## 🛠️ Hardware Used

* **FPGA Silicon Target:** [Xilinx Spartan-6 XC6SLX9](https://amd.com) (Mimas V2 Board)
* **Physical Interface Layer:** Onboard USB-to-UART Serial Bridge module
* **Oscillator Reference:** Onboard 100 MHz CMOS Clock Generation source
* **Host Interconnect:** USB Type A-to-Mini-B data transmission link cable

---

## 💻 Software Used

* **Development Environment:** [Xilinx ISE Design Suite](https://amd.com) (v14.7 project manager)
* **Simulation Engine:** Integrated ISim Logic Simulator
* **Hardware Floorplanner:** Xilinx PlanAhead Constraint Editor
* **Host Terminal Capture:** Any serial monitor emulator (PuTTY, Tera Term, Serial Studio)

---

## 📁 Project Structure

```text
FPGA_UART_DRIVER/
│
├── src/
│   └── top_module.v          # Top-Level Port Map & Structural Interconnect
├── third_party/
│   ├── Baud_generator.v      # Over-sampling Tick Clock Generator Module
│   ├── FIFO.v                # Dual circular memory array storage structures
│   ├── RX_module.v           # Asynchronous Serial Demodulation Frame Decoder
│   ├── TX_module.v           # Synchronous Bitstream Serialization Engine
│   └── uart_main.v           # Subsystem Integration Wrappers Core
├── ucf/
│   └── mimasV2.ucf           # Physical Pin Constraint Layer File
└── README.md
```

---

## 📐 System Connection Map & Data Topology

### 🔌 Physical Hardware Architecture

The modular UART controller partitions transmission operations into isolated logical layers inside the FPGA fabric. Data streams cross seamlessly from host system endpoints down through buffered storage registers:

```text
 ┌────────────────────────────────────────────────────────┐
 │               HOST COMPUTER / LAPTOP SYSTEM            │
 └──────────────────────────┬─────────────────────────────┘
                            │
                            │ USB Physical Interconnect
                            │ (Serial Telemetry Link)
                            ▼
 ┌────────────────────────────────────────────────────────┐
 │             ONBOARD USB-TO-UART SERIAL BRIDGE          │
 └───────┬────────────────────────────────────────┬───────┘
         │                                        │
         │ RX Data Wire                           │ TX Data Wire
         ▼                                        ▲
 ┌────────────────────────────────────────────────────────┐
 │              SPARTAN-6 FPGA SILICON FABRIC             │
 │                                                        │
 │   ┌───────────────┐               ┌───────────────┐    │
 │   │  RX_module.v  │ ────────────> │    FIFO.v     │    │
 │   │ (Demodulator) │               │   (Receive)   │    │
 │   └───────────────┘               └───────┬───────┘    │
 │                                           │            │
 │                                           ▼            │
 │                     Top-Level Application Logic        │
 │                     (Processing User Logic core)       │
 │                                           │            │
 │                                           ▼            │
 │   ┌───────────────┐               ┌───────┴───────┘    │
 │   │  TX_module.v  │ <──────────── │    FIFO.v     │    │
 │   │ (Serializer)  │               │ (Transmit)    │    │
 │   └───────────────┘               └───────────────┘    │
 │           ▲                                            │
 │           │ 16x Baud Tick Over-Sampling Line           │
 │   ┌───────┴───────┐                                    │
 │   │Baud_generator.v <── 100MHz Global Clock Pin        │
 │   └───────────────┘                                    │
 └────────────────────────────────────────────────────────┘
```

### 📌 Physical Pin Constraint Mappings (`mimasV2.ucf`)

| Module Register Pin | Signal Direction | FPGA Physical Pin Location | Target Component Interface Purpose |
| :--- | :--- | :--- | :--- |
| `CLK` | **Input** | **Pin P126** | Connected to global 100 MHz system clock circuit. |
| `RST` | **Input** | **User Pin Target** | Tied to a manual hardware reset momentary switch button. |
| `RX` | **Input** | **Pin P105** | Serial Rx line routed from onboard USB-UART bridge. |
| `TX` | **Output** | **Pin P104** | Serial Tx line routing back to onboard USB-UART bridge. |

---

## ⚙️ Working Principle

1. **Fractional Baud Selection:** The `Baud_generator` monitors the master hardware clock and divides frequencies to issue an over-sampling flag tick exactly 16 times the designated bit rate.
2. **Asynchronous Demodulation:** The `RX_module` loops continuously monitoring the incoming state of the serial line. Upon catching a `Start Bit` transition, it samples middle-bit intervals to decode standard 8-bit frames.
3. **Queue Interface Decoupling:** Decoded data bytes are dropped instantly into the receive `FIFO` array buffer, decoupling external bit transmission loops from internal processor speeds.
4. **Data Transmission Serialization:** Data bytes wait inside the transmission `FIFO` until the `TX_module` completes framing operations, appending boundary packets (`Start/Stop Bits`) and shifting the bitstream out.
5. **Bitstream Pipeline Stream:** Data passes off the physical FPGA output pin directly onto the terminal bridge controller chip, feeding clear text strings into host monitoring platforms.

---

## 🚀 Getting Started

### 1. Repository Setup
```bash
git clone https://github.com/Sushant456/FPGA_UART_DRIVER
```

### 2. Design Ingestion
* Launch **Xilinx ISE Project Navigator**.
* Open the project manifest file: `UART_FPGA_new.xise`.

### 3. Simulation Validation
* Change the design view toggle from `Synthesis` to `Simulation`.
* Expand the **ISim Simulator** menu tab option, and trigger **Run Simulation** to inspect the timing margins.

### 4. Compilation & Device Deployment
* Switch the workspace back into standard `Implementation` mode view.
* Right-click the design root entry module `top_module` and click **Generate Programming File**.
* Upload the compiled `top_module.bit` output file straight to the FPGA using your Mimas configuration programmer tool.

---

## 🔮 Future Improvements

* **Parity Checking Bits:** Integrating user-configurable parity generation modules to detect transmission noise failures.
* **Auto-Baud Synchronization:** Adding edge-detection modules to scale internal baud dividers automatically based on incoming synchronization frames.
* **Native AXI-Stream Wrappers:** Restructuring core module top boundaries into native AXI4-Stream protocols to allow plug-and-play IP block routing inside modern SoC system configurations.
