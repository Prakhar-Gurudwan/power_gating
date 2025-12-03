//==============================================================================
// IO Controller with Power Gating
// Features: Power domain control, output retention, activity monitoring
//==============================================================================
module IO_with_power_gating(
    input  wire clk,
    input  wire reset,
    input  wire [7:0] io_in,
    input  wire write_en,
    input  wire read_request,
    output reg  [7:0] io_out,
    output reg  idle_detect,
    output wire power_gated,
    output wire clk_gated
);
    parameter IDLE_THRESHOLD = 5;
    parameter POWER_GATE_DELAY = 2;
    
    // Internal registers
    reg [7:0] prev_io_in;
    reg [7:0] retained_out;
    reg [3:0] idle_counter;
    reg prev_write_en;
    reg prev_read_request;
    
    // Power management
    reg enable_clock;
    reg power_domain_on;
    reg [2:0] power_gate_counter;
    
    // Activity detection
    wire activity_detected;
    assign activity_detected = write_en ||
     read_request || (io_in != prev_io_in);
    
    // Clock gating
    assign clk_gated = clk & enable_clock;
    assign power_gated = ~power_domain_on;
    
    //==========================================================================
    // IO Operations and Power Management
    //==========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            io_out              <= 8'b00000000;
            retained_out        <= 8'b00000000;
            prev_io_in          <= 8'b00000000;
            prev_write_en       <= 1'b0;
            prev_read_request   <= 1'b0;
            idle_counter        <= 4'b0000;
            idle_detect         <= 1'b0;
            enable_clock        <= 1'b1;
            power_domain_on     <= 1'b1;
            power_gate_counter  <= 3'b000;
        end 
        else begin
            if (activity_detected) begin
                // Active operation
                if (write_en) begin
                    retained_out <= io_in;
                    io_out       <= io_in;
                end 
                else if (read_request) begin
                    io_out <= retained_out;
                end
                
                // Reset power management
                idle_counter        <= 4'b0000;
                idle_detect         <= 1'b0;
                enable_clock        <= 1'b1;
                power_domain_on     <= 1'b1;
                power_gate_counter  <= 3'b000;
            end 
            else begin
                // Increment idle counter
                if (idle_counter < IDLE_THRESHOLD +
                 POWER_GATE_DELAY) begin
                    idle_counter <= idle_counter + 1;
                end
                
                // Idle detection and power gating
                if (idle_counter >= IDLE_THRESHOLD) begin
                    idle_detect <= 1'b1;
                    
                  if (power_gate_counter < POWER_GATE_DELAY) begin
                     power_gate_counter <= power_gate_counter + 1;
                    end 
                    else begin
                        enable_clock    <= 1'b0;
                        power_domain_on <= 1'b0;
                    end
                end
                
                // Retain output
                io_out <= retained_out;
            end
            
            // Update previous values
            prev_io_in          <= io_in;
            prev_write_en       <= write_en;
            prev_read_request   <= read_request;
        end
    end
endmodule