# Import libraries
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

# Test
@cocotb.test()
async def riscv_cocotb(dut):
    """COCOTB START"""

    # 1ns Clock Start
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())

    # Reset - Active High
    for i in range(1):
        dut.rst.value = 0
        await Timer(1, "ns")
    dut.rst.value = 1
    for i in range(1):
        await Timer(2, "ns")
    dut.rst.value = 0
    cocotb.log.info("Reset done. Starting code")

    while(True):
        await Timer(1, "ns")

        # Identify that main function is being called
        if (dut.uut.wb_result.value == 0xCAFEBEEF):
            cocotb.log.info("Start Main") 
            
        # Finish Sim when we read DEADCODE (Added in start.s)
        if (dut.uut.wb_result.value == 0xDEADC0DE):
            #cocotb.log.info("End Main") 
            break 

