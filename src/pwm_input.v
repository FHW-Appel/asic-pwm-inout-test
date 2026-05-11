`default_nettype none
`timescale 8.333ns/8.333ps
// see ../docs/specification.md for module description

`ifdef FORMAL
    `define PRESCALER_MAX 7'd1
    `define PWM_INITIAL 7'd9
    `define PWM_ACTIVE_MAX 7'd20
`else
    `define PRESCALER_MAX 7'd119
    `define PWM_INITIAL 7'd99
    `define PWM_ACTIVE_MAX 7'd200
`endif

module pwm_input (
    input wire clk,
    input wire rst_n,
    input wire invert_polarity,
    input wire pwm_in,
    output reg [6:0] duty_cycle_i
    );

    // Pescaler counter to count up to 120 in order 
    // to generate 100 kHz frequency out of 12 MHz clock
    // The periode of the Pescaler is 10 us, which corresponds to 120 clock cycles at 12 MHz
    reg [6:0] prescaler_cnt; 

    // The PWM signal has a periode of 20 ms, which corresponds to 2000 Pescaler periods
    // Therfore, we need a counter that counts up to 2000
    // The duty cycle shall range from 5% (1 ms active time) to 10% (2 ms active time)
    reg [7:0] pwm_period_cnt; // Counter for duty cycle (0-100 and 100 to 200)
    reg [6:0] pwm_active; // Counter for active time (0-100) 5% up to 10%

    wire pwm_internal = invert_polarity ? ~pwm_in : pwm_in; // Handle polarity inversion
    reg pwm_in_d; // Delayed version of pwm_internal for edge detection

    always @(posedge clk) begin
        if (!rst_n) begin
            duty_cycle_i <= 7'd127; // Reset value corresponds to undefined duty cycle
            prescaler_cnt <= 7'b0;
            pwm_period_cnt <= 8'b0;   
            pwm_active <= 7'b0;
        end else begin
            if (pwm_internal && !pwm_in_d) begin
                // Rising edge detected, reset counters
                prescaler_cnt <= 7'b0;
                pwm_period_cnt <= 7'b0;   
                pwm_active <= 7'b0;
            end else if (!(prescaler_cnt == `PRESCALER_MAX)) begin
                prescaler_cnt <= prescaler_cnt + 1'b1;
            end else begin
                prescaler_cnt <= 7'b0;
                pwm_in_d <= pwm_internal; // Update delayed input for edge detection
                // Increment PWM period counter every 10 us
                pwm_period_cnt <= pwm_period_cnt + 1'b1;
                if (pwm_period_cnt > `PWM_INITIAL) begin
                    pwm_active <= pwm_active + 1'b1; // Increment active time counter after 1 ms
                end
                if (pwm_period_cnt > `PWM_ACTIVE_MAX) begin
                    duty_cycle_i <= 7'd125; // Error code 125 corresponds to more than 10% duty cycle
                    pwm_period_cnt <= pwm_period_cnt; // Stop counting to prevent overflow
                end else if (!pwm_internal && pwm_in_d) begin
                    // Falling edge detected
                    if (pwm_period_cnt < `PWM_INITIAL+1) begin
                        duty_cycle_i <= 7'd126; // Error code 126 corresponds to less than 5% duty cycle    
                    end else begin
                        duty_cycle_i <= pwm_active; // Update duty cycle with active time count                        
                    end
                end 
            end
        end
    end



`ifdef FORMAL

    reg f_past_valid = 0;

    initial assume (rst_n == 0);
    initial assume (duty_cycle_i == 7'd0);

    always @(posedge clk) begin
        
        a_cover_reset: cover(duty_cycle_i == 7'd127); // Cover reset value
        a_cover_lower_limit: cover(duty_cycle_i == 7'd126); // Cover case of less than 5% duty cycle
        a_cover_valid: cover(duty_cycle_i == 7'd2); // Cover case of valid duty cycle
        a_cover_upper_limit: cover(duty_cycle_i == 7'd125); // Cover case of more than 10% duty cycle

/*
        f_past_valid <= 1;

        if (f_past_valid) begin
            
        end
    
*/
    end

`endif

endmodule