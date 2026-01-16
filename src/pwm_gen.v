`default_nettype none
`timescale 8.333ns/8.333ps
// see ../docs/specification.md for module description

`ifdef FORMAL
    `define PRESCALER_MAX 7'd1
`else
    `define PRESCALER_MAX 7'd119
`endif

module pwm_gen (
    input wire clk, // he clock frequency is assumed to be 12 MHz
    input wire rst_n,
    input wire sel_inpins,
    input wire invert_polarity,
    output wire pwm_sig,
    input wire [6:0] reg_dc, // duty cycle register input
    input wire [6:0] pin_dc  // duty cycle pin input
    );

    // Pescaler counter to count up to 120 in order 
    // to generate 100 kHz frequency out of 12 MHz clock
    // The periode of the Pescaler is 10 us, which corresponds to 120 clock cycles at 12 MHz
    reg [6:0] prescaler_cnt; 

    // The PWM signal has a periode of 20 ms, which corresponds to 2000 Pescaler periods
    // Therfore, we need a counter that counts up to 2000
    // We can directly use the reg_dc or the pin_dc input to determine the active time of the PWM signal
    // The duty cycle shall range from 5% (1 ms active time) to 10% (2 ms active time)
    reg [10:0] pwm_period_cnt; // Counter for PWM period (0-2000)

    // Create PWM register and assign output with polarity inversion if needed
    reg duty_reg;
    assign pwm_sig = invert_polarity ? ~duty_reg : duty_reg;

    // Create a duty_cycle buffer register in order to prvent duty cycle changes during PWM period
    reg [6:0] duty_cycle_buf;

    always @(posedge clk) begin
        if (!rst_n) begin
            prescaler_cnt <= 7'b0;
            duty_reg <= 1'b0; // Default state of PWM signal
            pwm_period_cnt <= 11'b0;
            duty_cycle_buf <= sel_inpins ? pin_dc : reg_dc;
        end else begin
            // Generate PWM signal based on duty cycle
            // Active pulse: min 1 ms (100 periods), max 2 ms (200 periods)
            if ((pwm_period_cnt < 11'd100 + {4'b0, duty_cycle_buf}) && pwm_period_cnt < 11'd200) begin
                duty_reg <= 1'b1;
            end else begin
                duty_reg <= 1'b0;
            end               
            // Increment prescaler counter
            if (prescaler_cnt == `PRESCALER_MAX) begin
                prescaler_cnt <= 7'b0;
                // Increment PWM period counter every 10 us
                if (pwm_period_cnt == 11'd1999) begin
                    pwm_period_cnt <= 11'b0;
                    duty_cycle_buf <= sel_inpins ? pin_dc : reg_dc; // Update duty cycle buffer at the end of PWM period
                end else begin
                    pwm_period_cnt <= pwm_period_cnt + 11'b1;
                end
            end else begin
                prescaler_cnt <= prescaler_cnt + 7'b1;
            end
        end
    end

 endmodule

