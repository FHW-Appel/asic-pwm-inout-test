module if_spi (
    input wire clk,
    input wire rst_n,
    input wire spi_cs_n,
    input wire spi_sck,
    input wire spi_mosi,
    output reg spi_miso,
    // Register IF
    output reg [7:0] addr,
    output reg [7:0] data_in,
    output reg write_en,
    input wire [7:0] data_out
    );

// SPI rise and fall edge detection
reg spi_sck_prev;
wire sck_rising_edge, sck_falling_edge;
always @(posedge clk) begin
        spi_sck_prev <= spi_sck;
end
assign sck_rising_edge = (spi_sck == 1'b1) && (spi_sck_prev == 1'b0);
assign sck_falling_edge = (spi_sck == 1'b0) && (spi_sck_prev == 1'b1);

wire rst_internal;
assign rst_internal = (!rst_n) || spi_cs_n; // Reset internal state when reset is active or chip select is inactive 

//SPI shift register
reg [7:0] addr_int;
reg [7:0] data_int;
reg [3:0] bit_count;
reg [2:0] databit_count;
always @(posedge clk) begin
    if (rst_internal) begin
        addr_int <= 8'b0000_0000;
        addr <= 8'b0000_0000;
        data_int <= 8'b0000_0000;
        data_in <= 8'b0000_0000;
        bit_count <= 4'b0000;
        databit_count <= 3'b111; // Start from 7 for data bits
        write_en <= 1'b0;
        spi_miso <= 1'b0;
    end else begin
        write_en <= 1'b0; // Default to no write, will set to 1 when we have valid address/data

        if (sck_rising_edge) begin
            bit_count <= bit_count + 1;
            if (bit_count < 8) begin
                addr_int <= {addr_int[6:0], spi_mosi}; // Shift in address bits
            end else begin
                databit_count <= databit_count - 1;
                data_int <= {data_int[6:0], spi_mosi}; // Shift in data bits
            end   
            if (bit_count == 7) begin
                addr <= {addr_int[6:0], spi_mosi}; // Latch address after 8 bits
            end
            if (bit_count == 15) begin
                data_in <= {data_int[6:0], spi_mosi}; 
                write_en <= addr_int[7]; // Write operation if MSB of address is 1
            end
        end

        if (sck_falling_edge && bit_count > 7) begin
            spi_miso <= data_out[databit_count]; 
        end
    end
end

`ifdef FORMAL

reg f_past_valid = 0;

initial assume (rst_n == 0);

always @(posedge clk) begin
        


    f_past_valid <= 1;

    if (f_past_valid) begin
        assume(rst_n == 1); // Assume reset is released after the initial cycle
        a_cover_reset: cover(addr == 8'b0 && data_in == 8'b0 && write_en == 1'b0 && spi_miso == 1'b0); // Cover reset state
        
        assume(data_out == 8'b0101_0101); // Assume a specific value on data_out for testing
        a_cover_write: cover(data_in == 8'b0101_0101 && addr == 8'b1000_0001 && write_en == 1'b1); // Cover a specific write operation
    end
    

end

`endif

endmodule