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






    # Test register write and read back
 await write_reg(dut, 0, 20)  # reg_A = 20
    await write_reg(dut, 1, 20)  # reg_B = 20
    await write_reg(dut, 4, 0b0010)  # Opcode for multiply (OP_MUL=4'b0010)

    # Wait 2 cycles for calculation
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Read result (low and high bytes)
    result_low = await read_reg(dut, 5)
    result_high = await read_reg(dut, 6)
    result = (result_high << 8) | result_low

    print(f"Result: {result} (Expected: {20*20})")
    assert await tqv.read_reg(0) == 20

