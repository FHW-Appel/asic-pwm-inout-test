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


endmodule