`default_nettype none
`timescale 8.333ns/8.333ps

module pwm_gen_tb(
    input wire clk, // he clock frequency is assumed to be 12 MHz
    input wire rst_n,
    input wire sel_inpins,
    input wire invert_polarity,
    output wire pwm_sig,
    input wire [6:0] reg_dc, // duty cycle register input
    input wire [6:0] pin_dc  // duty cycle pin input
    );
    // create an instance of ../../src/pwm_gen for the testbench
    pwm_gen uut (
        .clk(clk),
        .rst_n(rst_n),
        .sel_inpins(sel_inpins),
        .invert_polarity(invert_polarity),
        .pwm_sig(pwm_sig),
        .reg_dc(reg_dc),
        .pin_dc(pin_dc)
    );

`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);

    always @(posedge clk) begin
        
        f_past_valid <= 1;

        // Assumption: rst_n is initially 0, then stays 1
        assume (rst_n == 1 || !f_past_valid);

        if (f_past_valid) begin
            // Cover checks

            // Cover pwm_sig goes high
            _c_prove_pwm_high_: cover(pwm_sig == 1'b1 && invert_polarity == 1'b0);

            // Cover pwm_sig goes low
            _c_prove_pwm_low_: cover(pwm_sig == 1'b0 && invert_polarity == 1'b0 && $past(rst_n) == 1'b1);

            // cover pwm_period_cnt reaches 4
            //_c_prove_pwm_period_cnt_4_: cover(uut.pwm_period_cnt == 11'd4);
            // ERROR: Cannot access uut.pwm_period_cnt. Yosys limitation!

            // Assert checks
            if ($past(rst_n) == 0) begin
                // After reset, pwm_sig should be low
                if (!invert_polarity) begin
                    _a_prove_reset_: assert(pwm_sig == 1'b0);
                end else begin
                    _a_prove_reset_invert_: assert(pwm_sig == 1'b1);
                end
            end
            
        end
    end

`endif

endmodule