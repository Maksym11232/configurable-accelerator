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
    await tqv.write_reg(0, 20)  # reg_A = 20
    await tqv.write_reg(1, 20)  # reg_B = 20
    await tqv.write_reg(4, 0b0010)  # OP_MUL (from your localparam)
    
    # Wait 2 cycles for calculation
    await ClockCycles(dut.clk, 3)
    
    hi = await tqv.read_reg(6)
    lo = await tqv.read_reg(5)
    print(f"High byte: {hi}, Low byte: {lo}")
    
    # Display and verify
    print(f"\n\x1b[36mTEST: 20 * 20 = {result}\x1b[0m")
    assert result == 400, "Multiplication failed!"
