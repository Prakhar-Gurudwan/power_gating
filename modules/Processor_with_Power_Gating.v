//==============================================================================
// Top-Level Processor with Power Gating
// Integrates ALU, Memory, IO, and Power Management Controller
//==============================================================================
module Processor_with_Power_Gating(
    input  wire clk,
    input  wire reset,
    
    // ALU Interface
    input  wire [3:0] alu_a,
    input  wire [3:0] alu_b,
    input  wire [2:0] alu_opcode,
    output wire [3:0] alu_result,
    
    // Memory Interface
    input  wire [3:0] mem_addr,
    input  wire [7:0] mem_data_in,
    input  wire mem_write_en,
    input  wire mem_req_valid,
    output wire [7:0] mem_data_out,
    
    // IO Interface
    input  wire [7:0] io_in,
    input  wire io_write_en,
    input  wire io_read_request,
    output wire [7:0] io_out,
    
    // Power Status Outputs
    output wire alu_idle,
    output wire mem_idle,
    output wire io_idle,
    output wire alu_power_gated,
    output wire mem_power_gated,
    output wire io_power_gated,
    output wire system_power_save_mode,
    output wire [1:0] active_modules_count,
    output wire [7:0] power_efficiency_metric,
    
    // Gated clocks for monitoring
    output wire alu_clk_gated,
    output wire mem_clk_gated,
    output wire io_clk_gated
);
    //==========================================================================
    // ALU Instance
    //==========================================================================
    ALU_with_power_gating alu_inst (
        .clk(clk),
        .reset(reset),
        .A(alu_a),
        .B(alu_b),
        .opcode(alu_opcode),
        .result(alu_result),
        .idle_detect(alu_idle),
        .power_gated(alu_power_gated),
        .clk_gated(alu_clk_gated)
    );
    
    //==========================================================================
    // Memory Instance
    //==========================================================================
    Memory_with_power_gating mem_inst (
        .clk(clk),
        .reset(reset),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .write_en(mem_write_en),
        .req_valid(mem_req_valid),
        .data_out(mem_data_out),
        .idle_detect(mem_idle),
        .power_gated(mem_power_gated),
        .clk_gated(mem_clk_gated)
    );
    
    //==========================================================================
    // IO Controller Instance
    //==========================================================================
    IO_with_power_gating io_inst (
        .clk(clk),
        .reset(reset),
        .io_in(io_in),
        .write_en(io_write_en),
        .read_request(io_read_request),
        .io_out(io_out),
        .idle_detect(io_idle),
        .power_gated(io_power_gated),
        .clk_gated(io_clk_gated)
    );
    
    //==========================================================================
    // Power Management Controller Instance
    //==========================================================================
    Power_Management_Controller pmc_inst (
        .clk(clk),
        .reset(reset),
        .alu_idle(alu_idle),
        .mem_idle(mem_idle),
        .io_idle(io_idle),
        .alu_power_gated(alu_power_gated),
        .mem_power_gated(mem_power_gated),
        .io_power_gated(io_power_gated),
        .system_power_save_mode(system_power_save_mode),
        .active_modules_count(active_modules_count),
        .power_efficiency_metric(power_efficiency_metric)
    );
    
endmodule