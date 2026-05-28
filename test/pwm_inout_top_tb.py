import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_pwm_inout_top(dut):
    await initialization(dut)
    cocotb.start_soon(Clock(dut.pwm_in, 3, unit="ms", period_high=1.5).start())
    await Timer(5, unit="ms")
    assert dut.opins.value == 50, f"Expected opins to be 50, got {dut.opins.value}"

async def initialization(dut):
    cocotb.start_soon(Clock(dut.clk, 83, unit="ns", period_high=40).start())
    cocotb.start_soon(Clock(dut.spi_sck, 200, unit="ns").start())
    # Initialize SPI signals to avoid X values
    dut.spi_cs_n.value = 1
    dut.spi_mosi.value = 0
    dut.ipins.value = 20
    dut.rst_n.value = 0
    await Timer(20, unit="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    