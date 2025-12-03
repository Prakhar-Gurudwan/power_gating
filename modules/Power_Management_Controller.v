//==============================================================================
// Central Power Management Controller
// Coordinates power gating across all modules
//==============================================================================
module Power_Management_Controller(
    input  wire clk,
    input  wire reset,
    
    // Idle signals from modules
    input  wire alu_idle,
    input  wire mem_idle,
    input  wire io_idle,
    
    // Power gating status from modules
    input  wire alu_power_gated,
    input  wire mem_power_gated,
    input  wire io_power_gated,
    
    // System-wide power status
    output reg  system_power_save_mode,
    output reg  [1:0] active_modules_count,
    output reg  [7:0] power_efficiency_metric
);
    // Power state tracking
    reg [7:0] total_cycles;
    reg [7:0] gated_cycles;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            system_power_save_mode  <= 1'b0;
            active_modules_count    <= 2'b11;
            power_efficiency_metric <= 8'd0;
            total_cycles            <= 8'd0;
            gated_cycles            <= 8'd0;
        end 
        else begin
            // Track total cycles
            if (total_cycles < 8'd255)
                total_cycles <= total_cycles + 1;
            
            // Count active modules
            active_modules_count <= (~alu_power_gated) + (~mem_power_gated) + (~io_power_gated);
            
            // System in power save if all modules are gated
            system_power_save_mode <= alu_power_gated & mem_power_gated & io_power_gated;
            
            // Count gated cycles
            if (system_power_save_mode && gated_cycles < 8'd255)
                gated_cycles <= gated_cycles + 1;
            
            // Calculate power efficiency (percentage of time in power save mode)
            if (total_cycles > 0)
                power_efficiency_metric <= (gated_cycles * 100) / total_cycles;
        end
    end
endmodule