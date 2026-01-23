# RISC-V Benchmarking Framework

This repository provides a testing framework for RISC-V based processors. I includes riscv-tests, dhrystone benchmark and coremark benchmark. It also includes a test.c file in folder custom_c_test for writing and testing c based programs.
It was tested on a simplified version of my [RISC-V SoC](https://github.com/TalhaIsrar/RISCV-RV32IM-AXI4-Lite-SoC). The design is evolving as more bugs are being found.

## 🔄 Usage
To run any of the tests, after installing the pre-requisties, you can run the following commands:

```bash
make custom
make riscv-tests
make dhrystone
make coremark
```

## 🛠️ Prerequisites

* Linux / WSL
* **RISC-V GNU Toolchain** (`riscv32-unknown-elf-gcc 15.2.0`)
* **Verilator** (`v5.042`)
* **cocotb** (`2.0.1`)
* Gtkwave (optional)

---

## 📦 Installation

### 1️⃣ RISC-V GNU Toolchain (RV32I)

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
```

```bash
sudo apt-get install -y autoconf automake autotools-dev curl python3 python3-pip \
libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf \
libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake \
libglib2.0-dev libslirp-dev libncurses-dev
```

```bash
./configure --prefix=$HOME/riscv32i --with-arch=rv32i --with-abi=ilp32
make
```

```bash
echo 'export RISCV=$HOME/riscv32i' >> ~/.bashrc
echo 'export PATH=$RISCV/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

```bash
riscv32-unknown-elf-gcc --version
```

---

### 2️⃣ Verilator

```bash
sudo apt-get install -y git help2man perl python3 make autoconf g++ flex bison \
ccache libgoogle-perftools-dev numactl perl-doc \
libfl2 libfl-dev zlib1g zlib1g-dev
```

```bash
git clone https://github.com/verilator/verilator
cd verilator
git checkout stable
autoconf && ./configure && make
sudo make install
```

```bash
verilator --version
```

---

### 3️⃣ cocotb (Python Virtual Environment)

```bash
sudo apt-get install -y python3 python3-pip python3-venv libpython3-dev
```

```bash
python3 -m venv ~/cocotb
source ~/cocotb/bin/activate
pip install cocotb cocotb-bus cocotb-test
```

```bash
python3 -c "import cocotb; print('cocotb OK')"
```

---