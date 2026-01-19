`default_nettype none
`timescale 8.333ns/8.333ps
// see ../docs/specification.md for module description
module out_stage (
    input wire clk,
    input wire rst_n,
    input wire sel_pwm,
    input wire invert_polarity,
    input wire [6:0] ovalues,
    input wire [6:0] pwm_dc,
    output reg [6:0] opins
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            opins <= 7'b0;
        end else begin
            if (sel_pwm) begin
                if (invert_polarity) begin
                    opins <= ~pwm_dc;
                end else begin
                    opins <= pwm_dc;
                end
            end else begin
                if (invert_polarity) begin
                    opins <= ~ovalues;
                end else begin
                    opins <= ovalues;
                end
            end
        end
    end



`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    always @(posedge clk) begin
        
        f_past_valid <= 1;

        if (f_past_valid) begin
            
            // Cover the invert behavior when sel_pwm is set
            _c_prove_invert_pwm_: cover($past(sel_pwm) && $past(invert_polarity) && $past(pwm_dc) == ~opins && opins != 7'b0);

            // Cover the non-invert behavior when sel_pwm is set
            _c_prove_no_invert_pwm_: cover($past(sel_pwm) && !$past(invert_polarity) && $past(pwm_dc) == opins && opins != 7'b0);

            // Cover the invert behavior when sel_pwm is not set
            _c_prove_invert_ovalues_: cover(!$past(sel_pwm) && $past(invert_polarity) && $past(ovalues) == ~opins && opins != 7'b0);

            // Cover the non-invert behavior when sel_pwm is not set
            _c_prove_no_invert_ovalues_: cover(!$past(sel_pwm) && !$past(invert_polarity) && $past(ovalues) == opins && opins != 7'b0);

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