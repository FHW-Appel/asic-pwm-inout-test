`default_nettype none
`timescale 8.333ns/8.333ps
// see ../docs/specification.md for module description

module in_stage (
    input wire clk,
    input wire rst_n,
    input wire invert_polarity,
    input wire [6:0] ipins,
    output reg [6:0] ivalues
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            ivalues <= 7'b0;
        end else begin
            if (invert_polarity) begin
                ivalues <= ~ipins;
            end else begin
                ivalues <= ipins;
            end
        end
    end



`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    always @(posedge clk) begin
        
        f_past_valid <= 1;

        if (f_past_valid) begin
            
            // Cover the invert behavior
            _c_prove_invert_: cover($past(invert_polarity) && $past(ipins) == ~ivalues && ivalues != 7'b0);

            // Cover the non-invert behavior
            _c_prove_no_invert_: cover(!$past(invert_polarity) && $past(ipins) == ivalues && ivalues != 7'b0);

            // After reset, ivalues should be zero
            if ($past(rst_n) == 0) begin
                _a_prove_reset_: assert(ivalues == 7'b0);
            end else begin
                // Check behavior based on invert_polarity
                if ($past(invert_polarity)) begin
                    _a_prove_invert_: assert(ivalues == ~$past(ipins));
                end else begin
                    _a_prove_no_invert_: assert(ivalues == $past(ipins));
                end
            end
        end

    end
`endif

endmodule