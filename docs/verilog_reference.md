# Verilog Reference

A comprehensive guide to Verilog HDL for digital design.

## Introduction

### What is a Hardware Description Language (HDL)?

A Hardware Description Language (HDL) is a specialized programming language used to describe the structure and behavior of electronic circuits, particularly digital logic circuits. Unlike software code that executes sequentially on a processor, HDL code describes hardware that operates concurrently and in parallel.

**Key Differences from Software Code:**
- **Parallelism**: Hardware components operate simultaneously, not sequentially
- **Timing**: HDL must account for propagation delays and clock cycles
- **Synthesis**: Code is converted into physical hardware gates and flip-flops
- **Concurrency**: Multiple operations happen at the same time

**Applications:**
- **FPGA (Field-Programmable Gate Array)**: Reconfigurable hardware chips
- **CPLD (Complex Programmable Logic Device)**: Smaller programmable devices
- **ASIC (Application-Specific Integrated Circuit)**: Custom silicon chips

### Different HDLs

**Verilog**: C-like syntax, widely used in industry, particularly in the US and Asia. Simple and concise.

**VHDL**: Ada-like syntax, strongly typed, verbose, commonly used in Europe and aerospace/defense.

**SystemVerilog**: Extension of Verilog with enhanced verification features, object-oriented programming constructs, and improved modeling capabilities.

**Chisel/SpinalHDL**: Modern HDLs built on top of Scala, offering higher-level abstractions.

### Why Verilog?

- **Industry standard**: Widely adopted in semiconductor industry
- **Simpler syntax**: Less verbose than VHDL, easier to learn
- **Extensive tool support**: Supported by all major EDA tools
- **Open-source tools**: Good support in open-source synthesis tools (Yosys, Verilator)
- **Flexible**: Supports both behavioral and structural descriptions
- **Active community**: Large user base and extensive documentation

## Basic Structure

### Syntax Notation and Highlighting

Verilog is case-sensitive and uses C-style comments:
- Single-line comments: `//`
- Multi-line comments: `/* ... */`

Keywords are typically lowercase, and statements end with semicolons.

### Module (Entity)

A **module** is the basic building block in Verilog, equivalent to an entity in VHDL. It defines the interface (ports) and behavior of a hardware component.

**General Structure:**
```verilog
module module_name (
    input wire input_signal,
    output wire [7:0] autput_vector,
    output wire output_signal,
    output reg output_register
);
    // Internal signals and logic here
    
endmodule
```

**Explicit Example:**
```verilog
module counter (
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [7:0] count
);
    // Counter implementation
    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 8'h00;
        else if (enable)
            count <= count + 1;
    end
    
endmodule
```

### Architecture (Implementation)

In Verilog, the module architecture is integrated within the module definition itself, unlike VHDL where entity and architecture are separate.

**General Structure:**
```verilog
module module_name (/* ports */);
    // Internal signal declarations
    wire internal_signal;
    reg [3:0] state;
    
    // Concurrent assignments (combinational logic)
    assign output = input1 & input2;
    
    // Sequential logic blocks
    always @(posedge clk) begin
        // Sequential statements
    end
    
    // Module instantiations
    submodule_name instance_name (
        .port1(signal1),
        .port2(signal2)
    );
    
endmodule
```

**Explicit Example:**
```verilog
module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [1:0] op,
    output reg [7:0] result
);
    // Combinational logic using always block
    always @(*) begin
        case (op)
            2'b00: result = a + b;
            2'b01: result = a - b;
            2'b10: result = a & b;
            2'b11: result = a | b;
        endcase
    end
    
endmodule
```

### Libraries

Verilog uses compiler directives and include statements for libraries:

```verilog
`timescale 1ns/1ps      // Time unit / Time precision
`include "definitions.vh"  // Include header file
`define WIDTH 8          // Define macro
```

## Concurrent Assignments

Concurrent assignments describe combinational logic that evaluates continuously whenever inputs change.

### Assignment

Use the `assign` keyword for continuous assignments:

```verilog
assign output1 = input1 & input2;
assign sum = a + b;
assign eq = (a == b);
```

### Logic Operators

**Bitwise operators:**
- `&` : AND
- `|` : OR
- `^` : XOR
- `~` : NOT
- `~&`: NAND
- `~|`: NOR

**Logical operators:**
- `&&`: Logical AND
- `||`: Logical OR
- `!` : Logical NOT

**Arithmetic operators:**
- `+`, `-`, `*`, `/`, `%` (modulo)

**Comparison operators:**
- `==`, `!=`, `<`, `<=`, `>`, `>=`

**Shift operators:**
- `<<` : Left shift
- `>>` : Right shift
- `<<<`: Arithmetic left shift
- `>>>`: Arithmetic right shift

**Example:**
```verilog
assign and_result = a & b;           // Bitwise AND
assign or_result = a | b;            // Bitwise OR
assign xor_result = a ^ b;           // Bitwise XOR
assign not_result = ~a;              // Bitwise NOT
assign logical_and = (a > 0) && (b > 0);  // Logical AND
assign sum = a + b;                  // Addition
assign shifted = a << 2;             // Left shift by 2
```

### Brackets

- **Parentheses `()`**: Group expressions, module ports
- **Square brackets `[]`**: Bit selection, array indexing
- **Curly braces `{}`**: Concatenation

```verilog
assign result = (a + b) * c;        // Grouping
assign bit = data[3];                // Bit selection
assign byte = data[7:0];             // Range selection
assign concat = {a, b, c};           // Concatenation
```

### Signals

**Wire**: For combinational logic, continuous assignments
```verilog
wire enable;
wire [7:0] data_bus;
```

**Reg**: For sequential logic, used in always blocks (doesn't necessarily imply a register)
```verilog
reg state;
reg [3:0] counter;
```

**Integer**: For simulation and loops
```verilog
integer i;
```

### Signal Vectors

Vectors represent multi-bit signals:

```verilog
wire [7:0] byte_data;      // 8-bit vector [7:0]
reg [15:0] word_data;       // 16-bit vector [15:0]
wire [31:0] dword;          // 32-bit vector

// Bit selection
assign bit_3 = byte_data[3];

// Range selection (slice)
assign upper_nibble = byte_data[7:4];
assign lower_nibble = byte_data[3:0];

// Assignment with specific bits
assign result = {4'b0000, byte_data[3:0]};  // Pad with zeros
```

### Lookup Table (LUT)

Lookup tables can be implemented using case statements or memory arrays:

```verilog
// Using case statement
always @(*) begin
    case (address)
        3'b000: data_out = 8'h12;
        3'b001: data_out = 8'h34;
        3'b010: data_out = 8'h56;
        3'b011: data_out = 8'h78;
        3'b100: data_out = 8'h9A;
        3'b101: data_out = 8'hBC;
        3'b110: data_out = 8'hDE;
        3'b111: data_out = 8'hF0;
    endcase
end

// Using memory array
reg [7:0] lut [0:7];
initial begin
    lut[0] = 8'h12;
    lut[1] = 8'h34;
    // ... etc
end
assign data_out = lut[address];
```

### Concatenation and Replication

**Concatenation** combines multiple signals:
```verilog
assign bus = {byte_high, byte_low};  // 16-bit from two 8-bit
assign padded = {8'h00, data};        // Zero-extend
```

**Replication** repeats a pattern:
```verilog
assign all_ones = {8{1'b1}};          // 8'b11111111
assign pattern = {4{2'b10}};          // 8'b10101010
```

### Default Values

In case statements, use `default` to handle all unspecified cases:

```verilog
always @(*) begin
    case (select)
        2'b00: out = a;
        2'b01: out = b;
        2'b10: out = c;
        default: out = d;  // Handles 2'b11 and any x/z states
    endcase
end
```

### Conditional Assignment (Ternary Operator)

The ternary operator `?:` provides a concise way to express conditional logic:

```verilog
assign output = condition ? value_if_true : value_if_false;

// Examples:
assign max = (a > b) ? a : b;
assign abs = (value[7]) ? -value : value;
assign mux_out = sel ? input1 : input0;

// Nested ternary (use sparingly for readability)
assign result = (sel == 2'b00) ? a :
                (sel == 2'b01) ? b :
                (sel == 2'b10) ? c : d;
```

### Component Instances (Module Instantiation)

Module instantiation allows you to use a previously defined module within another module, creating hierarchical designs.

**Block Diagram Concept:**
```
┌─────────────────────┐
│   Parent Module     │
│                     │
│  ┌──────────────┐   │
│  │  Instance 1  │   │
│  │  (counter)   │   │
│  └──────────────┘   │
│                     │
│  ┌──────────────┐   │
│  │  Instance 2  │   │
│  │  (counter)   │   │
│  └──────────────┘   │
└─────────────────────┘
```

**Module Declaration** (the component to be instantiated):
```verilog
module counter (
    input wire clk,
    input wire rst,
    input wire enable,
    output wire [7:0] count
);
    // Implementation here
endmodule
```

**Positional Instantiation** (not recommended):
```verilog
counter cnt1 (clk, rst, en1, count1);
```

**Named Port Instantiation** (recommended):
```verilog
// Short version - one line per port
counter counter_inst (
    .clk(system_clock),
    .rst(system_reset),
    .enable(counter_enable),
    .count(counter_value)
);

// Long version - with explicit types and more spacing
counter counter_instance_1 (
    .clk    (system_clock),
    .rst    (system_reset),
    .enable (enable_signal_1),
    .count  (count_output_1)
);

// Multiple instances
counter cnt0 (
    .clk(clk),
    .rst(rst),
    .enable(en0),
    .count(count0)
);

counter cnt1 (
    .clk(clk),
    .rst(rst),
    .enable(en1),
    .count(count1)
);
```

**With Parameters:**
```verilog
module parameterized_counter #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rst,
    output reg [WIDTH-1:0] count
);
    // Implementation
endmodule

// Instantiation with parameter override
parameterized_counter #(.WIDTH(16)) cnt16 (
    .clk(clk),
    .rst(rst),
    .count(wide_count)
);
```

## Sequential Assignments

Sequential assignments describe behavior that occurs on clock edges or specific events, typically implementing registers and state machines.

### Processes (Always Blocks)

The `always` block is the fundamental construct for describing sequential and combinational logic.

**Combinational Logic:**
```verilog
// Use always @(*) for combinational logic
always @(*) begin
    // All inputs must be in sensitivity list (use *)
    result = a + b;
end

// Alternative explicit sensitivity list
always @(a or b or c) begin
    result = (a & b) | c;
end
```

**Sequential Logic (Synchronous):**
```verilog
// Triggered on clock edge
always @(posedge clk) begin
    q <= d;  // Use non-blocking assignment (<=) for sequential
end

// With asynchronous reset
always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 1'b0;
    else
        q <= d;
end
```

**Important: Blocking vs Non-Blocking Assignments**
- **Non-blocking (`<=`)**: Use in sequential (clocked) always blocks
  - Assignments happen in parallel at end of time step
  - Models concurrent hardware behavior
  
- **Blocking (`=`)**: Use in combinational always blocks
  - Assignments happen immediately in order
  - More like procedural software code

```verilog
// Sequential - use non-blocking
always @(posedge clk) begin
    temp <= input_data;
    output_data <= temp;    // Creates a 2-stage pipeline
end

// Combinational - use blocking
always @(*) begin
    temp = a & b;
    result = temp | c;      // Executes in order
end
```

### Case Statements

Case statements implement multi-way branches, often synthesized as multiplexers or lookup tables.

```verilog
always @(*) begin
    case (selector)
        2'b00: output = input0;
        2'b01: output = input1;
        2'b10: output = input2;
        2'b11: output = input3;
    endcase
end

// With default
always @(*) begin
    case (opcode)
        4'h0: result = a + b;
        4'h1: result = a - b;
        4'h2: result = a & b;
        4'h3: result = a | b;
        default: result = 8'h00;  // Prevents unintended latches
    endcase
end

// casez - treats 'z' as don't care
always @(*) begin
    casez (instruction)
        8'b0000_????: type = LOAD;
        8'b0001_????: type = STORE;
        default: type = NOP;
    endcase
end
```

### If-Then-Else Statements

If-else statements create priority-encoded logic where conditions are evaluated in order.

**Priority Structure:**
```verilog
always @(*) begin
    if (condition1)
        output = value1;      // Highest priority
    else if (condition2)
        output = value2;      // Second priority
    else if (condition3)
        output = value3;      // Third priority
    else
        output = default_value;  // Lowest priority (catch-all)
end
```

**Example:**
```verilog
always @(*) begin
    if (enable == 0)
        state_next = IDLE;
    else if (error)
        state_next = ERROR;
    else if (done)
        state_next = COMPLETE;
    else
        state_next = RUNNING;
end
```

**Note:** Priority logic can create longer combinational paths than case statements. Use case when all conditions are mutually exclusive and no priority is needed.

### Registers

Registers are fundamental storage elements in digital design, typically implemented with flip-flops.

**Asynchronous Reset:**
```verilog
// Reset takes effect immediately, regardless of clock
always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 1'b0;  // Reset has priority
    else
        q <= d;      // Normal operation
end
```

**Synchronous Reset:**
```verilog
// Reset is sampled on clock edge
always @(posedge clk) begin
    if (rst)
        q <= 1'b0;  // Reset on clock edge
    else
        q <= d;
end
```

**Synchronous Enable:**
```verilog
// Register only updates when enabled
always @(posedge clk) begin
    if (rst)
        q <= 1'b0;
    else if (enable)
        q <= d;     // Only update when enabled
    // else q retains its value
end
```

### Finite State Machines (FSM)

FSMs are used to implement sequential control logic with distinct states and transitions.

**State Machine Diagram Concept:**
```
       ┌─────────┐
       │  RESET  │
       └────┬────┘
            │
       ┌────▼────┐
   ┌───┤  IDLE   ◄───┐
   │   └────┬────┘   │
   │        │ start  │
   │   ┌────▼────┐   │
   │   │ RUNNING │───┘done
   │   └────┬────┘   
   │        │ error 
   │   ┌────▼────┐  
   └──►│  ERROR  ├
       └─────────┘
```

#### State Definition

**Using Parameters:**
```verilog
module fsm (
    input wire clk,
    input wire rst,
    input wire start,
    input wire done,
    output reg busy
);
    // State encoding
    parameter IDLE    = 2'b00;
    parameter RUNNING = 2'b01;
    parameter DONE    = 2'b10;
    parameter ERROR   = 2'b11;
    
    reg [1:0] state, next_state;
    
    // ... FSM logic ...
endmodule
```

**Using Localparam (preferred for internal constants):**
```verilog
localparam IDLE    = 3'b000;
localparam START   = 3'b001;
localparam ACTIVE  = 3'b010;
localparam WAIT    = 3'b011;
localparam FINISH  = 3'b100;

reg [2:0] state, next_state;
```

#### Two-Process FSM

Separates state register (sequential) from next-state logic (combinational). This is the recommended style for most designs.

```verilog
module two_process_fsm (
    input wire clk,
    input wire rst,
    input wire start,
    input wire done,
    output reg busy,
    output reg [7:0] counter
);
    localparam IDLE    = 2'b00;
    localparam RUNNING = 2'b01;
    localparam FINISH  = 2'b10;
    
    reg [1:0] state, next_state;
    
    // Process 1: State register (sequential)
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Process 2: Next state logic and outputs (combinational)
    always @(*) begin
        // Default assignments to prevent latches
        next_state = state;
        busy = 1'b0;
        
        case (state)
            IDLE: begin
                busy = 1'b0;
                if (start)
                    next_state = RUNNING;
            end
            
            RUNNING: begin
                busy = 1'b1;
                if (done)
                    next_state = FINISH;
            end
            
            FINISH: begin
                busy = 1'b0;
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Optional: Third process for registered outputs
    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 8'h00;
        else if (state == RUNNING)
            counter <= counter + 1;
    end
    
endmodule
```

**Pitfall - Unintentional Latches:**
In combinational always blocks, always provide default values or cover all cases to avoid synthesizing unwanted latches:

```verilog
// BAD - creates latch
always @(*) begin
    case (state)
        IDLE: next_state = START;
        START: next_state = RUNNING;
        // RUNNING case missing - creates latch!
    endcase
end

// GOOD - no latch
always @(*) begin
    next_state = state;  // Default assignment
    case (state)
        IDLE: if (start) next_state = START;
        START: next_state = RUNNING;
        RUNNING: if (done) next_state = IDLE;
    endcase
end
```

#### One-Process FSM

Combines state register and logic into a single sequential block. Simpler but less flexible.

```verilog
module one_process_fsm (
    input wire clk,
    input wire rst,
    input wire start,
    input wire done,
    output reg busy
);
    localparam IDLE    = 2'b00;
    localparam RUNNING = 2'b01;
    localparam FINISH  = 2'b10;
    
    reg [1:0] state;
    
    // Single process: state transitions and logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            busy <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    if (start)
                        state <= RUNNING;
                end
                
                RUNNING: begin
                    busy <= 1'b1;
                    if (done)
                        state <= FINISH;
                end
                
                FINISH: begin
                    busy <= 1'b0;
                    state <= IDLE;
                end
                
                default: begin
                    state <= IDLE;
                    busy <= 1'b0;
                end
            endcase
        end
    end
    
endmodule
```

**Pitfall - Registered Outputs:**
In one-process FSMs, all outputs are registered (delayed by one clock cycle). This may not always be desirable:

```verilog
// Output busy is delayed - changes one cycle after state change
always @(posedge clk) begin
    case (state)
        IDLE: busy <= 1'b0;  // busy changes cycle after entering IDLE
        RUNNING: busy <= 1'b1;
    endcase
end

// If you need combinational output, use two-process style or:
always @(*) begin
    case (state)
        IDLE: busy_comb = 1'b0;  // Immediate output
        RUNNING: busy_comb = 1'b1;
    endcase
end
```

## Simulation

### Testbench and Stimuli

A testbench is a Verilog module that instantiates the DUT and provides stimulus.

**Basic Testbench Structure:**
```verilog
`timescale 1ns/1ps

module testbench;
    // Signals to connect to DUT
    reg clk;
    reg rst;
    reg [7:0] data_in;
    wire [7:0] data_out;
    
    // Instantiate DUT
    my_design dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Generate stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        data_in = 8'h00;
        
        // Release reset after 100ns
        #100 rst = 0;
        
        // Apply test vectors
        #20 data_in = 8'h12;
        #20 data_in = 8'h34;
        #20 data_in = 8'h56;
        
        // End simulation
        #100 $finish;
    end
    
    // Optional: VCD dump for waveform viewing
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);
    end
    
endmodule
```

### Testbench Clock Generation

Several methods to generate a clock signal:

**Method 1: Using always block**
```verilog
reg clk;
initial clk = 0;
always #5 clk = ~clk;  // 10ns period (100 MHz)
```

**Method 2: Forever loop**
```verilog
reg clk;
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
```

**Method 3: Specific period**
```verilog
parameter CLOCK_PERIOD = 10;  // 10ns = 100 MHz
reg clk;
initial begin
    clk = 0;
    forever #(CLOCK_PERIOD/2) clk = ~clk;
end
```

**Method 4: With duty cycle control**
```verilog
reg clk;
initial begin
    clk = 0;
    forever begin
        #3 clk = 1;  // 3ns high
        #7 clk = 0;  // 7ns low (30% duty cycle)
    end
end
```

### Testbench with Stimuli and Monitor

A more complete testbench includes monitoring and checking:

```verilog
`timescale 1ns/1ps

module testbench_with_monitor;
    reg clk;
    reg rst;
    reg enable;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire valid;
    
    integer errors;
    
    // Instantiate DUT
    my_design dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .data_in(data_in),
        .data_out(data_out),
        .valid(valid)
    );
    
    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz
    
    // Stimulus generation
    initial begin
        // Initialize
        errors = 0;
        rst = 1;
        enable = 0;
        data_in = 8'h00;
        
        // VCD dump
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench_with_monitor);
        
        // Reset sequence
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);
        
        // Test case 1
        $display("Test Case 1: Basic operation");
        enable = 1;
        data_in = 8'h5A;
        @(posedge clk);
        
        // Wait for valid output
        wait(valid == 1);
        @(posedge clk);
        if (data_out !== 8'hA5) begin
            $display("ERROR: Expected 0xA5, got 0x%h", data_out);
            errors = errors + 1;
        end else begin
            $display("PASS: Correct output 0x%h", data_out);
        end
        
        // Test case 2
        $display("Test Case 2: Disabled operation");
        enable = 0;
        data_in = 8'hFF;
        repeat(3) @(posedge clk);
        if (valid !== 0) begin
            $display("ERROR: Valid should be low when disabled");
            errors = errors + 1;
        end else begin
            $display("PASS: Valid correctly low");
        end
        
        // More test cases...
        
        // Summary
        #100;
        $display("\n========================================");
        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("TESTS FAILED: %0d errors", errors);
        $display("========================================\n");
        
        $finish;
    end
    
    // Monitor block - continuously display changes
    initial begin
        $monitor("Time=%0t rst=%b enable=%b data_in=%h data_out=%h valid=%b",
                 $time, rst, enable, data_in, data_out, valid);
    end
    
    // Assertions (optional - for formal verification)
    // Check that output is stable when valid is high
    always @(posedge clk) begin
        if (!rst && valid) begin
            if ($past(valid) && (data_out !== $past(data_out))) begin
                $display("ERROR at %0t: Output changed while valid was high", $time);
            end
        end
    end
    
endmodule
```

**Key Monitoring Techniques:**

1. **$display**: Print once when executed
2. **$monitor**: Automatically print when any signal changes
3. **$strobe**: Print at end of current time step (after all non-blocking assignments)
4. **Assertions**: Check conditions during simulation

**Example Monitor Patterns:**
```verilog
// Simple monitor
initial $monitor("t=%0t: state=%b count=%d", $time, state, count);

// Conditional monitoring
always @(posedge clk) begin
    if (error)
        $display("ERROR detected at time %0t", $time);
end

// Periodic status
initial begin
    forever begin
        #1000;  // Every 1000ns
        $display("Status: Processed %0d items", item_count);
    end
end
```

---

## Summary

This reference covers the essential Verilog concepts for digital design:

1. **Structural Elements**: Modules, ports, signals
2. **Concurrent Logic**: Continuous assignments, combinational operations
3. **Sequential Logic**: Always blocks, registers, state machines
4. **Verification**: Testbenches, simulation, monitoring

**Additional Resources:**
- IEEE Standard 1364-2005 (Verilog)
- "Verilog HDL" by Samir Palnitkar
- "RTL Modeling with SystemVerilog for Simulation and Synthesis" by Stuart Sutherland
- Open-source tools: Yosys, Icarus Verilog, Verilator, GTKWave
