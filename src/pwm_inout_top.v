`default_nettype none
//`timescale 8.333ns/83.33ps
// see ../docs/specification.md for module description

module pwm_inout_top
     (
    input wire clk,
    input wire rst_n,
    // SPI Interface
    input wire spi_cs_n,
    input wire spi_sck,
    input wire spi_mosi,
    output wire spi_miso,
    // Inputs
    input wire [6:0] ipins,
    input wire pwm_in,
    // Outputs
    output wire [6:0] opins,
    output wire pwm_sig
);

    // Register interface signals
    wire [7:0] addr;
    wire [7:0] data_in;
    wire write_en;
    wire [7:0] data_out;
    
    // Instantiate of the if_spi module discribed in if_spi.v
    if_spi if_spi_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .spi_cs_n       (spi_cs_n),
    .spi_sck        (spi_sck),
    .spi_mosi       (spi_mosi),
    .spi_miso       (spi_miso),
    // Register IF
    .addr           (addr),
    .data_in        (data_in),
    .write_en       (write_en),
    .data_out       (data_out)
    );

    // Internal signals for connecting submodules
    wire [7:0] Pinout;
    wire [7:0] Pinin;
    wire [7:0] PWMgen;
    wire [7:0] PWMin;
    wire [7:0] Polarity;

    // Instantiate of the register module discribed in register.v 
    register register_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .data_in        (data_in),
    .addr           (addr[2:0]),
    .write_en       (write_en),
    .data_out       (data_out),
    // Internal registers
    .Pinout         (Pinout),
    .Pinin          (Pinin),
    .PWMgen         (PWMgen),
    .PWMin          (PWMin),
    .Polarity       (Polarity)
    );


    // Instantiate of the pwm_gen module discribed in pwm_gen.v
    pwm_gen pwm_gen_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .sel_inpins     (PWMgen[7]),
    .invert_polarity(Polarity[2]),
    .pwm_sig        (pwm_sig),
    .reg_dc         (PWMgen[6:0]),
    .pin_dc         (Pinin[6:0])
    );

    // Instantiate of the in_stage module discribed in in_stage.v
    in_stage in_stage_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .invert_polarity(Polarity[3]),
    .ipins          (ipins),
    .ivalues        (Pinin[6:0])
    );

    // Instantiate of the out_stage module discribed in out_stage.v
    out_stage out_stage_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .sel_pwm        (Pinout[7]),
    .invert_polarity(Polarity[4]),
    .ovalues        (Pinout[6:0]),
    .pwm_dc         (PWMin[6:0]),
    .opins          (opins)
    );

    // Instantiate of the pwm_input module discribed in pwm_input.v
    pwm_input pwm_input_inst (
    .clk            (clk),
    .rst_n          (rst_n),
    .invert_polarity(Polarity[1]),
    .pwm_in         (pwm_in),
    .duty_cycle_i   (PWMin[6:0])
    );

endmodule

module cocotb_iverilog_dump();
    initial begin
        $dumpfile("sim_build/pwm_inout_top.vcd");
        $dumpvars(0, pwm_inout_top);
        #1;
    end
endmodule