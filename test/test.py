# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    tqv = TinyQV(dut)

    # Reset, always start the test by resetting TinyQV
    await tqv.reset()

    dut._log.info("Test project behavior")






 # Test 20 * 20
    await tqv.write_reg(0, 10)  # reg_A = 10
    await tqv.write_reg(1, 20)  # reg_B = 20
    await tqv.write_reg(2, 30)  # reg_C = 30
    await tqv.write_reg(3, 40)  # reg_D = 40

    
    await tqv.write_reg(4, 0b0000)  
    await ClockCycles(dut.clk, 3)
    
    A = await tqv.read_reg(0)
    B = await tqv.read_reg(1)
    C = await tqv.read_reg(2)
    D = await tqv.read_reg(3)

    Op = await tqv.read_reg(4)

    res = await tqv.read_reg(5)
    
    print(f"A: {A}, B: {B}, C: {C}, D: {D}, OP:{Op}, res: {res}")

