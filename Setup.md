# RISCV Benchmarking Framework

# 🛠️ Prerequisites

To run this project, ensure the following tools are installed:

1. **Linux / WSL**
2. **RISC-V GNU Toolchain**
   *Tested:* `riscv32-unknown-elf-gcc (g5115c7e44) 15.2.0`
3. **Verilator**
   *Tested:* `Verilator 5.044 2026-01-01 rev v5.044-52-g7e7b6d7fb`
4. **cocotb**
   *Tested:* `Version 2.0.1`
5. **Gtkwave (Optional)**

---

# 📦 Installation Guide

## 1. Install RISC-V GNU Toolchain

### Clone repo

```bash
git clone https://github.com/riscv/riscv-gnu-toolchain
cd ./riscv-gnu-toolchain/
```

### Install dependencies

```bash
sudo apt-get install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libncurses-dev
```

### Configure and make
```bash
./configure --prefix=$HOME/riscv32i --with-arch=rv32i --with-abi=ilp32
make
```

### Add to PATH
```bash
export RISCV=$HOME/riscv32i
export PATH=$RISCV/bin:$PATH
echo 'export RISCV=$HOME/riscv32i' >> ~/.bashrc
echo 'export PATH=$RISCV/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Check installation
```bash
riscv32-unknown-elf-gcc --version
```

---

## 2. Install Verilator

### Install dependencies

```bash
sudo apt-get install git help2man perl python3 make autoconf g++ flex bison ccache
sudo apt-get install libgoogle-perftools-dev numactl perl-doc
sudo apt-get install libfl2
sudo apt-get install libfl-dev
sudo apt-get install zlibc zlib1g zlib1g-dev
```

### Clone repo

```bash
git clone https://github.com/verilator/verilator
cd verilator
```

### Select stable branch
```bash
git checkout stable
```

### Configure and make
```bash
autoconf
./configure
make
```

### Check installation
```bash
make test
sudo make install
verilator --version
```

---

## 3. Install cocotb

### Install Python & dependencies

```bash
sudo apt-get install make python3 python3-pip libpython3-dev
```

### Install Python virtual environment tools

```bash
sudo apt install python3-venv python3-full
```

### Create and activate a virtual environment for cocotb

```bash
python3 -m venv ~/cocotb
source ~/cocotb/bin/activate
```

### Install cocotb packages

```bash
pip install cocotb cocotb-bus cocotb-test
```

### Verify installation

```bash
python3 -c "import cocotb; print('cocotb OK')"
```

---