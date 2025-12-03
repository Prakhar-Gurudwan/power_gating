
module Memory_with_power_gating(
    input  wire clk,
    input  wire reset,
    input  wire [3:0] addr,
    input  wire [7:0] data_in,
    input  wire write_en,
    input  wire req_valid,
    output reg  [7:0] data_out,
    output reg  idle_detect,
    output wire power_gated,
    output wire clk_gated
);
    parameter IDLE_THRESHOLD = 5;
    parameter POWER_GATE_DELAY = 2;
    

    reg [7:0] mem [0:15];
    
    // Activity tracking
    reg [3:0] prev_addr;
    reg [7:0] prev_data_in;
    reg prev_write_en;
    reg prev_req_valid;
    reg [3:0] idle_counter;
    
    
    reg enable_clock;
    reg power_domain_on;
    reg [2:0] power_gate_counter;
    reg [7:0] data_retention;
    
   
    wire activity_detected;
    assign activity_detected = req_valid || 
                               (addr != prev_addr) || 
                               (data_in != prev_data_in) || 
                               (write_en != prev_write_en);
    
    // Clock gating
    assign clk_gated = clk & enable_clock;
    assign power_gated = ~power_domain_on;
    
  
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out            <= 8'b00000000;
            prev_addr           <= 4'b0000;
            prev_data_in        <= 8'b00000000;
            prev_write_en       <= 1'b0;
            prev_req_valid      <= 1'b0;
            idle_counter        <= 4'b0000;
            idle_detect         <= 1'b0;
            enable_clock        <= 1'b1;
            power_domain_on     <= 1'b1;
            power_gate_counter  <= 3'b000;
            data_retention      <= 8'b00000000;
            
           
            for (i = 0; i < 16; i = i + 1) begin
                mem[i] <= 8'b00000000;
            end
        end 
        else begin
            if (activity_detected) begin
                // Active operation
                if (req_valid) begin
                    if (write_en) begin
                        mem[addr]       <= data_in;
                        data_out        <= data_in;
                        data_retention  <= data_in;
                    end 
                    else begin
                        data_out        <= mem[addr];
                        data_retention  <= mem[addr];
                    end
                end
                
            
                idle_counter        <= 4'b0000;
                idle_detect         <= 1'b0;
                enable_clock        <= 1'b1;
                power_domain_on     <= 1'b1;
                power_gate_counter  <= 3'b000;
            end 
            else begin
                
                if (idle_counter < IDLE_THRESHOLD + POWER_GATE_DELAY) begin
                    idle_counter <= idle_counter + 1;
                end
                
                
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
                
              
                data_out <= data_retention;
            end
            
            
            prev_addr       <= addr;
            prev_data_in    <= data_in;
            prev_write_en   <= write_en;
            prev_req_valid  <= req_valid;
        end
    end
endmodule
