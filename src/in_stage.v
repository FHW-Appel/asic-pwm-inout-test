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


endmodule