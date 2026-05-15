module register (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire [2:0] addr,
    input wire write_en,
    output wire [7:0] data_out,
    // Internal registers
    output reg [7:0]Pinout,
    input wire [7:0]Pinin,
    output reg [7:0]PWMgen,
    input wire [7:0]PWMin,
    output reg [7:0]Polarity   
); 

// Read logic are combinational and can read from any address
assign data_out = (addr == 3'h4) ? Pinout :
                  (addr == 3'h3) ? Pinin :
                  (addr == 3'h2) ? PWMgen :
                  (addr == 3'h1) ? PWMin :
                  (addr == 3'h0) ? Polarity : 8'b0;

// Write logic only apply to even addresses (0, 2, 4)
always @(posedge clk) begin
    if (!rst_n) begin
        Pinout <= 8'b1000_0000;
        PWMgen <= 8'b1000_0000;
        Polarity <= 8'b0000_0000;
    end else if (write_en && ~addr[0]) begin
        case (addr)
            3'h4: Pinout <= data_in;
            3'h2: PWMgen <= data_in;
            3'h0: Polarity <= data_in;
        endcase
    end
end

`ifdef FORMAL

reg f_past_valid = 0;

initial assume (rst_n == 0);

always @(posedge clk) begin
        


    f_past_valid <= 1;

    if (f_past_valid) begin
        assume(rst_n == 1); // Assume reset is released after the initial cycle
        a_cover_reset: cover(Pinout == 8'b1000_0000 && PWMgen == 8'b1000_0000 && Polarity == 8'b0000_0000 ); // Cover reset value
        a_cover_write: cover(Pinout == 8'b1010_1010 && PWMgen == 8'b0101_0101 && Polarity == 8'b1111_0000); // Cover write value
            
    end
    

end

`endif

endmodule