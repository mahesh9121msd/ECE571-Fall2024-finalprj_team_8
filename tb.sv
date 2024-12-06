`timescale 1ns / 1ps
import apb_pkg::*;
module apb_mem_tb();
    logic PCLK_t, PRESETn_t;
	
	// Interface instantiation
    apb_if apb_if_inst(.PCLK(PCLK_t), .PRESETn(PRESETn_t)); 
    logic [31:0] pass_count = 0;  // Counter for passed tests
    logic [31:0] fail_count = 0;  // Counter for failed tests

    // Instantiate DUT
    apb_mem #(.RDY_COUNT(1)) apb_mem_inst (.PCLK(PCLK_t),.PRESETn(PRESETn_t),.apb(apb_if_inst));
    // Write task
    task write_task(input [9:0] addr_in, input [31:0] data_in);
        apb_if_inst.PSEL = 1;
        apb_if_inst.PADDR = addr_in;
        apb_if_inst.PWRITE = 1;
        apb_if_inst.PENABLE = 0;
        apb_if_inst.PWDATA = data_in;
        @(posedge PCLK_t);
        apb_if_inst.PENABLE = 1;
        @(posedge PCLK_t);
        while (!apb_if_inst.PREADY) begin
            @(posedge PCLK_t);
        end
        apb_if_inst.PENABLE = 0;
        apb_if_inst.PWRITE = 0;
    endtask

    // Read task
    task read_task(input [9:0] addr_in);
        apb_if_inst.PSEL = 1;
        apb_if_inst.PADDR = addr_in;
        apb_if_inst.PWRITE = 0;
        apb_if_inst.PENABLE = 0;
        @(posedge PCLK_t);
        apb_if_inst.PENABLE = 1;
        @(posedge PCLK_t);
        while (!apb_if_inst.PREADY) begin
            @(posedge PCLK_t);
        end
        // Self-checking logic
        if (check_wr_rd_data(addr_in, apb_if_inst.PWDATA, apb_if_inst.PRDATA)) begin
            pass_count++;
        end else begin
            fail_count++;
        end
        apb_if_inst.PENABLE = 0;
        apb_if_inst.PWRITE = 1;
    endtask

    // Self-checking function
    function int check_wr_rd_data(input logic [9:0] addr, input logic [31:0] expected_data, input logic [31:0] actual_data);
        $display($time, " Checking addr=%0h, expected_data=%0h, actual_data=%0h", addr, expected_data, actual_data);
        if (expected_data == actual_data) begin
            $display("PASS: Data matched at address %0h", addr);
            return 1;
        end else begin
            $display("FAIL: Data mismatch at address %0h", addr);
            return 0;
        end
    endfunction

    // Test case 1: Single write and read test
    task automatic single_wr_rd_test();
        write_task(10, 32'h1234_5678);
        read_task(10);
    endtask

    // Test case 2: All memory write and read test
    task automatic all_wr_rd_test();
        for (int count = 0; count < 1024; count++) begin
            logic [31:0] data_in = $random;
            write_task(count, data_in);
            read_task(count);
        end
    endtask

    // Test case 3: Pattern test
    task automatic pattern_test();
        for (int count = 0; count < 1024; count++) begin
            write_task(count, 32'haaaa_aaaa);
            read_task(count);
            write_task(count, 32'h5555_5555);
            read_task(count);
        end
    endtask

    // Generate clock
    always #5 PCLK_t = ~PCLK_t;

    // Initial block for reset and test execution
    initial begin
       
        PCLK_t = 0;
        PRESETn_t = 0;
        #15;
        PRESETn_t = 1;
        @(posedge PCLK_t);

        // Execute test cases
        single_wr_rd_test();
        all_wr_rd_test();
        pattern_test();

        // Display test results
        $display("======================================================");
        $display("Test Summary:");
        $display("Total Passed: %0d", pass_count);
        $display("Total Failed: %0d", fail_count);
        $display("======================================================");
        #1000;$finish;
    end
endmodule
