`default_nettype none
`timescale 1ns/1ps

// This module is a testbench for the out_stage module 
// in order to test its functionality using SymbiYosys (sby).
// See https://symbiyosys.readthedocs.io/en/latest/index.html
// for more information on SymbiYosys and formal verification.

module in_stage_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg invert_polarity;
    reg [6:0] ipins;
    wire [6:0] ivalues;

    // create an instance of ../../src/in_stage for the testbench

    in_stage uut (
        .clk(clk),
        .rst_n(rst_n),
        .invert_polarity(invert_polarity),
        .ipins(ipins),
        .ivalues(ivalues)
    );

`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    always @(posedge clk) begin
        
        f_past_valid <= 1;

        if (f_past_valid) begin
            // After reset, ivalues should be zero
            if ($past(rst_n) == 0) begin
                assert(ivalues == 7'b0);
            end else begin
                // Check behavior based on invert_polarity
                if ($past(invert_polarity)) begin
                    assert(ivalues == ~$past(ipins));
                end else begin
                    assert(ivalues == $past(ipins));
                end
            end
        end

    end
`endif

endmodule