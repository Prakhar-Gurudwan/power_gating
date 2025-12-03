//==============================================================================
// ALU with Power Gating and Idle Detection
// Features: Clock gating, power domain control, activity monitoring
//==============================================================================
module ALU_with_power_gating(
    input  wire clk,
    input  wire reset,
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] opcode,
    output reg  [3:0] result,
    output reg  idle_detect,
    output wire power_gated,        // Power gating status
    output wire clk_gated           // Gated clock output for monitoring
);
    // Parameters
    parameter IDLE_THRESHOLD = 5;
    parameter POWER_GATE_DELAY = 2;  // Cycles before power gating
    
    // Internal registers
    reg [3:0] prev_A, prev_B;
    reg [2:0] prev_opcode;
    reg [3:0] idle_counter;
    reg [3:0] alu_out;
    reg [3:0] result_retention;      // Retained result during power gating
    
    // Power management
    reg enable_clock;                // Clock enable signal
    reg power_domain_on;             // Power domain control
    reg [2:0] power_gate_counter;    // Delay before actual power gating
    
    // Activity detection
    wire activity_detected;
    assign activity_detected = (A != prev_A) 
    || (B != prev_B) || (opcode != prev_opcode);
    
    // Clock gating
    assign clk_gated = clk & enable_clock;
    assign power_gated = ~power_domain_on;
    
    //==========================================================================
    // ALU Combinational Logic
    //==========================================================================
    always @(*) begin
        case (opcode)
            3'b000: alu_out = A + B;              // Addition
            3'b001: alu_out = A - B;              // Subtraction
            3'b010: alu_out = A & B;              // AND
            3'b011: alu_out = A | B;              // OR
            3'b100: alu_out = A ^ B;              // XOR
            3'b101: alu_out = ~A;                 // NOT
            3'b110: alu_out = A << 1;             // Left shift
            3'b111: alu_out = A >> 1;             // Right shift
            default: alu_out = 4'b0000;
        endcase
    end
    
    //==========================================================================
    // Power Management and Idle Detection
    //==========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_A              <= 4'b0000;
            prev_B              <= 4'b0000;
            prev_opcode         <= 3'b000;
            idle_counter        <= 4'b0000;
            idle_detect         <= 1'b0;
            result              <= 4'b0000;
            result_retention    <= 4'b0000;
            enable_clock        <= 1'b1;
            power_domain_on     <= 1'b1;
            power_gate_counter  <= 3'b000;
        end 
        else begin
            // Activity detection and idle counter management
            if (activity_detected) begin
                idle_counter        <= 4'b0000;
                idle_detect         <= 1'b0;
                enable_clock        <= 1'b1;
                power_domain_on     <= 1'b1;
                power_gate_counter  <= 3'b000;
                result              <= alu_out;
                result_retention    <= alu_out;
            end 
            else begin
                // Increment idle counter
                if (idle_counter < IDLE_THRESHOLD + POWER_GATE_DELAY) begin
                    idle_counter <= idle_counter + 1;
                end
                
                // Idle detection
                if (idle_counter >= IDLE_THRESHOLD) begin
                    idle_detect <= 1'b1;
                    
                    // Power gating logic with delay
                    if (power_gate_counter < POWER_GATE_DELAY) begin
                        power_gate_counter <= power_gate_counter + 1;
                    end 
                    else begin
                        enable_clock    <= 1'b0;  // Clock gating
                        power_domain_on <= 1'b0;  // Power gating
                    end
                end
                
                // Retain result during idle
                result <= result_retention;
            end
            
            // Update previous values
            prev_A      <= A;
            prev_B      <= B;
            prev_opcode <= opcode;
        end
    end
endmodule