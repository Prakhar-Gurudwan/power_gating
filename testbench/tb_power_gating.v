//==============================================================================
// Comprehensive Testbench for Power Gating System
// Tests 6 different scenarios with power consumption analysis
//==============================================================================
`timescale 1ns/1ps

module tb_power_gating;
    // Clock and reset
    reg clk;
    reg reset;
    
    // ALU signals
    reg [3:0] alu_a, alu_b;
    reg [2:0] alu_opcode;
    wire [3:0] alu_result;
    
    // Memory signals
    reg [3:0] mem_addr;
    reg [7:0] mem_data_in;
    reg mem_write_en;
    reg mem_req_valid;
    wire [7:0] mem_data_out;
    
    // IO signals
    reg [7:0] io_in;
    reg io_write_en;
    reg io_read_request;
    wire [7:0] io_out;
    
    // Power status signals
    wire alu_idle, mem_idle, io_idle;
    wire alu_power_gated, mem_power_gated, io_power_gated;
    wire system_power_save_mode;
    wire [1:0] active_modules_count;
    wire [7:0] power_efficiency_metric;
    wire alu_clk_gated, mem_clk_gated, io_clk_gated;
    
    // Power calculation variables
    real active_power = 100.0;      // Power in mW when active
    real idle_power = 50.0;         // Power in mW when idle (clock gated)
    real gated_power = 5.0;         // Power in mW when power gated
    
    integer total_cycles;
    integer alu_active_cycles, alu_idle_cycles, alu_gated_cycles;
    integer mem_active_cycles, mem_idle_cycles, mem_gated_cycles;
    integer io_active_cycles, io_idle_cycles, io_gated_cycles;
    
    real alu_energy, mem_energy, io_energy, total_energy;
    real baseline_energy, power_savings_percent;
    
    // File for output
    integer file;
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Processor_with_Power_Gating dut (
        .clk(clk),
        .reset(reset),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_opcode(alu_opcode),
        .alu_result(alu_result),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_write_en(mem_write_en),
        .mem_req_valid(mem_req_valid),
        .mem_data_out(mem_data_out),
        .io_in(io_in),
        .io_write_en(io_write_en),
        .io_read_request(io_read_request),
        .io_out(io_out),
        .alu_idle(alu_idle),
        .mem_idle(mem_idle),
        .io_idle(io_idle),
        .alu_power_gated(alu_power_gated),
        .mem_power_gated(mem_power_gated),
        .io_power_gated(io_power_gated),
        .system_power_save_mode(system_power_save_mode),
        .active_modules_count(active_modules_count),
        .power_efficiency_metric(power_efficiency_metric),
        .alu_clk_gated(alu_clk_gated),
        .mem_clk_gated(mem_clk_gated),
        .io_clk_gated(io_clk_gated)
    );
    
    //==========================================================================
    // Clock Generation (10ns period = 100MHz)
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    //==========================================================================
    // Power Monitoring
    //==========================================================================
    always @(posedge clk) begin
        if (!reset) begin
            total_cycles = total_cycles + 1;
            
            // Track ALU states
            if (!alu_power_gated && !alu_idle) 
                alu_active_cycles = alu_active_cycles + 1;
            else if (alu_idle && !alu_power_gated) 
                alu_idle_cycles = alu_idle_cycles + 1;
            else if (alu_power_gated) 
                alu_gated_cycles = alu_gated_cycles + 1;
            
            // Track Memory states
            if (!mem_power_gated && !mem_idle) 
                mem_active_cycles = mem_active_cycles + 1;
            else if (mem_idle && !mem_power_gated) 
                mem_idle_cycles = mem_idle_cycles + 1;
            else if (mem_power_gated) 
                mem_gated_cycles = mem_gated_cycles + 1;
            
            // Track IO states
            if (!io_power_gated && !io_idle) 
                io_active_cycles = io_active_cycles + 1;
            else if (io_idle && !io_power_gated) 
                io_idle_cycles = io_idle_cycles + 1;
            else if (io_power_gated) 
                io_gated_cycles = io_gated_cycles + 1;
        end
    end
    
    //==========================================================================
    // Power Calculation Task
    //==========================================================================
    task calculate_power;
        input [200*8:1] test_name;
        begin
            // Energy = Power × Time
            // Time per cycle = 10ns
            alu_energy = (alu_active_cycles * active_power + 
                         alu_idle_cycles * idle_power + 
                         alu_gated_cycles * gated_power) * 10e-9;
            
            mem_energy = (mem_active_cycles * active_power + 
                         mem_idle_cycles * idle_power + 
                         mem_gated_cycles * gated_power) * 10e-9;
            
            io_energy = (io_active_cycles * active_power + 
                        io_idle_cycles * idle_power + 
                        io_gated_cycles * gated_power) * 10e-9;
            
            total_energy = alu_energy + mem_energy + io_energy;
            
            // Baseline: All modules always active
            baseline_energy = total_cycles * 3 * active_power * 10e-9;
            
            // Power savings percentage
            power_savings_percent = ((baseline_energy - total_energy) / baseline_energy) * 100.0;
            
            // Display results
            $display("\n========================================");
            $display("Test Case: %s", test_name);
            $display("========================================");
            $display("Total Cycles: %0d", total_cycles);
            $display("\nALU Statistics:");
            $display("  Active cycles: %0d", alu_active_cycles);
            $display("  Idle cycles: %0d", alu_idle_cycles);
            $display("  Power-gated cycles: %0d", alu_gated_cycles);
            $display("  Energy consumed: %0f mJ", alu_energy * 1000);
            
            $display("\nMemory Statistics:");
            $display("  Active cycles: %0d", mem_active_cycles);
            $display("  Idle cycles: %0d", mem_idle_cycles);
            $display("  Power-gated cycles: %0d", mem_gated_cycles);
            $display("  Energy consumed: %0f mJ", mem_energy * 1000);
            
            $display("\nIO Statistics:");
            $display("  Active cycles: %0d", io_active_cycles);
            $display("  Idle cycles: %0d", io_idle_cycles);
            $display("  Power-gated cycles: %0d", io_gated_cycles);
            $display("  Energy consumed: %0f mJ", io_energy * 1000);
            
            $display("\nTotal Energy: %0f mJ", total_energy * 1000);
            $display("Baseline Energy (no power gating): %0f mJ", baseline_energy * 1000);
            $display("Power Savings: %0f%%", power_savings_percent);
            $display("========================================\n");
            
            // Write to file
            $fwrite(file, "\n========================================\n");
            $fwrite(file, "Test Case: %s\n", test_name);
            $fwrite(file, "========================================\n");
            $fwrite(file, "Total Cycles: %0d\n", total_cycles);
            $fwrite(file, "\nALU: Active=%0d, Idle=%0d, Gated=%0d, Energy=%0f mJ\n", 
                    alu_active_cycles, alu_idle_cycles, alu_gated_cycles, alu_energy * 1000);
            $fwrite(file, "Memory: Active=%0d, Idle=%0d, Gated=%0d, Energy=%0f mJ\n", 
                    mem_active_cycles, mem_idle_cycles, mem_gated_cycles, mem_energy * 1000);
            $fwrite(file, "IO: Active=%0d, Idle=%0d, Gated=%0d, Energy=%0f mJ\n", 
                    io_active_cycles, io_idle_cycles, io_gated_cycles, io_energy * 1000);
            $fwrite(file, "\nTotal Energy: %0f mJ\n", total_energy * 1000);
            $fwrite(file, "Baseline Energy: %0f mJ\n", baseline_energy * 1000);
            $fwrite(file, "Power Savings: %0f%%\n", power_savings_percent);
            $fwrite(file, "========================================\n\n");
        end
    endtask
    
    //==========================================================================
    // Reset Task
    //==========================================================================
    task reset_counters;
        begin
            total_cycles = 0;
            alu_active_cycles = 0;
            alu_idle_cycles = 0;
            alu_gated_cycles = 0;
            mem_active_cycles = 0;
            mem_idle_cycles = 0;
            mem_gated_cycles = 0;
            io_active_cycles = 0;
            io_idle_cycles = 0;
            io_gated_cycles = 0;
        end
    endtask
    
    //==========================================================================
    // Initialize Signals Task
    //==========================================================================
    task init_signals;
        begin
            alu_a = 4'b0000;
            alu_b = 4'b0000;
            alu_opcode = 3'b000;
            mem_addr = 4'b0000;
            mem_data_in = 8'b00000000;
            mem_write_en = 1'b0;
            mem_req_valid = 1'b0;
            io_in = 8'b00000000;
            io_write_en = 1'b0;
            io_read_request = 1'b0;
        end
    endtask
    
    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    initial begin
        // Open output file
        file = $fopen("power_analysis_results.txt", "w");
        
        // Initialize signals
        init_signals();
        reset = 1;
        
        // Generate VCD for waveform viewing
        $dumpfile("power_gating.vcd");
        $dumpvars(0, tb_power_gating);
        
        // Apply reset
        #20 reset = 0;
        #20;
        
        //======================================================================
        // TEST CASE 1: Continuous ALU Activity (No Power Savings)
        //======================================================================
        $display("\n>>> Starting Test Case 1: Continuous ALU Activity");
        reset_counters();
        #10;
        
        repeat (30) begin
            alu_a = $random % 16;
            alu_b = $random % 16;
            alu_opcode = $random % 8;
            #10;
        end
        
        calculate_power("Test 1: Continuous ALU Activity");
        init_signals();
        #50;
        
        //======================================================================
        // TEST CASE 2: ALU Bursts with Idle Periods (Clock Gating)
        //======================================================================
        $display("\n>>> Starting Test Case 2: ALU Bursts with Idle");
        reset_counters();
        #10;
        
        // Burst 1
        repeat (5) begin
            alu_a = $random % 16;
            alu_b = $random % 16;
            alu_opcode = $random % 8;
            #10;
        end
        // Idle period
        init_signals();
        #100; 
        // Burst 2
        repeat (5) begin
            alu_a = $random % 16;
            alu_b = $random % 16;
            alu_opcode = $random % 8;
            #10;
        end
        
        // Long idle period (power gating)
        init_signals();
        #150;
        
        calculate_power("Test 2: ALU Bursts with Idle Periods");
        #50;
        
        //======================================================================
        // TEST CASE 3: Memory-Intensive Workload
        //======================================================================
        $display("\n>>> Starting Test Case 3: Memory-Intensive Workload");
        reset_counters();
        #10;
        // Write operations
        repeat (10) begin
            mem_addr = $random % 16;
            mem_data_in = $random % 256;
            mem_write_en = 1'b1;
            mem_req_valid = 1'b1;
            #10;
        end
        // Idle period
        mem_write_en = 1'b0;
        mem_req_valid = 1'b0;
        #80;
        // Read operations
        repeat (10) begin
            mem_addr = $random % 16;
            mem_write_en = 1'b0;
            mem_req_valid = 1'b1;
            #10;
        end
        // Long idle (power gating)
        mem_req_valid = 1'b0;
        #150;
        calculate_power("Test 3: Memory-Intensive Workload");
        init_signals();
        #50;
        
        //======================================================================
        // TEST CASE 4: IO-Intensive Operations
        //======================================================================
        $display("\n>>> Starting Test Case 4: IO-Intensive Operations");
        reset_counters();
        #10;
        
        // IO write burst
        repeat (8) begin
            io_in = $random % 256;
            io_write_en = 1'b1;
            #10;
        end
        
        io_write_en = 1'b0;
        #60;
        
        // IO read burst
        repeat (8) begin
            io_read_request = 1'b1;
            #10;
        end
        
        io_read_request = 1'b0;
        #120;
        
        calculate_power("Test 4: IO-Intensive Operations");
        init_signals();
        #50;
        
        //======================================================================
        // TEST CASE 5: Mixed Workload (All modules active at different times)
        //======================================================================
        $display("\n>>> Starting Test Case 5: Mixed Workload");
        reset_counters();
        #10;
        
        // Phase 1: ALU activity
        repeat (5) begin
            alu_a = $random % 16;
            alu_b = $random % 16;
            alu_opcode = $random % 8;
            #10;
        end
        init_signals();
        #40;
        
        // Phase 2: Memory activity
        repeat (5) begin
            mem_addr = $random % 16;
            mem_data_in = $random % 256;
            mem_write_en = 1'b1;
            mem_req_valid = 1'b1;
            #10;
        end
        mem_write_en = 1'b0;
        mem_req_valid = 1'b0;
        #40;
        
        // Phase 3: IO activity
        repeat (5) begin
            io_in = $random % 256;
            io_write_en = 1'b1;
            #10;
        end
        io_write_en = 1'b0;
        #40;
        
        // Phase 4: All modules idle (maximum power savings)
        init_signals();
        #150;
        
        calculate_power("Test 5: Mixed Workload");
        #50;
        
        //======================================================================
        // TEST CASE 6: Realistic Processor Simulation
        //======================================================================
        $display("\n>>> Starting Test Case 6: Realistic Processor Simulation");
        reset_counters();
        #10;
        
        // Simulate instruction fetch and execution pattern
        repeat (3) begin
            // Fetch instruction (Memory read)
            mem_addr = $random % 16;
            mem_req_valid = 1'b1;
            mem_write_en = 1'b0;
            #10;
            mem_req_valid = 1'b0;
            #10;
            
            // Execute (ALU operation)
            alu_a = $random % 16;
            alu_b = $random % 16;
            alu_opcode = $random % 8;
            #20;
            alu_a = 4'b0000;
            alu_b = 4'b0000;
            
            // Write back (Memory write)
            mem_addr = $random % 16;
            mem_data_in = $random % 256;
            mem_write_en = 1'b1;
            mem_req_valid = 1'b1;
            #10;
            mem_write_en = 1'b0;
            mem_req_valid = 1'b0;
            
            // Pipeline bubble / idle time
            #30;
        end
        
        // IO operation
        io_in = 8'hAA;
        io_write_en = 1'b1;
        #10;
        io_write_en = 1'b0;
        
        // Long idle period (processor sleep)
        init_signals();
        #200;
        
        calculate_power("Test 6: Realistic Processor Simulation");
        
        //======================================================================
        // End Simulation
        //======================================================================
        #100;
        $fclose(file);
        $display("\n>>> All tests completed!");
        $display(">>> Results saved to power_analysis_results.txt");
        $finish;
    end
    
    //==========================================================================
    // Timeout Watchdog
    //==========================================================================
    initial begin
        #50000;
        $display("\nERROR: Simulation timeout!");
        $finish;
    end
    
endmodule