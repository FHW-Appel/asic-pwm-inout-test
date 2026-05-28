.PHONY: cocotb

cocotb:
	$(MAKE) -f $(shell cocotb-config --makefiles)/Makefile.sim \
		SIM=icarus \
		WAVES=1 \
		VERILOG_SOURCES=$(PWD)/../src/*.v \
		TOPLEVEL=pwm_inout_top \
		COCOTB_TEST_MODULES=pwm_inout_top_tb