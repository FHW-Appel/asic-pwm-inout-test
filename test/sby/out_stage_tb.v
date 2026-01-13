`default_nettype none
`timescale 1ns/1ps

// This module is a testbench for the out_stage module 
// in order to test its functionality using SymbiYosys (sby).
// See https://symbiyosys.readthedocs.io/en/latest/index.html
// for more information on SymbiYosys and formal verification.

module out_stage_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg sel_pwm;
    reg invert_polarity;
    reg [6:0] ovalues;
    reg [6:0] pwm_dc;
    wire [6:0] opins;

// create an instance of ../../src/out_stage for the testbench

    out_stage uut (
        .clk(clk),
        .rst_n(rst_n),
        .sel_pwm(sel_pwm),
        .invert_polarity(invert_polarity),
        .ovalues(ovalues),
        .pwm_dc(pwm_dc),
        .opins(opins)
    );


`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    always @(posedge clk) begin
        
        f_past_valid <= 1;

        if (f_past_valid) begin
            // After reset, opins should be zero
            if ($past(rst_n) == 0) begin
                assert(opins == 7'b0);
            end else begin
                // Check behavior based on sel_pwm and invert_polarity
                if ($past(sel_pwm)) begin
                    if ($past(invert_polarity)) begin
                        assert(opins == ~$past(pwm_dc));
                    end else begin
                        assert(opins == $past(pwm_dc));
                    end
                end else begin
                    if ($past(invert_polarity)) begin
                        assert(opins == ~$past(ovalues));
                    end else begin
                        assert(opins == $past(ovalues));
                    end
                end
            end
        end

    end




`endif
    
endmodule