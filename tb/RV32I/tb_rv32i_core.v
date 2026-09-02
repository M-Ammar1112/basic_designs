`timescale 1ns/1ps

module tb_rv32i_core;

    localparam integer MEMORY_BYTES = 4096;

    reg clk;
    reg reset;
    wire [31:0] instruction_address;
    reg [31:0] instruction;
    wire data_valid;
    wire data_write;
    wire [31:0] data_address;
    wire [31:0] data_write_data;
    wire [3:0] data_byte_enable;
    reg [31:0] data_read_data;
    wire halted;

    reg [31:0] instruction_memory [0:1023];
    reg [7:0] data_memory [0:MEMORY_BYTES - 1];
    integer index;

    rv32i_core uut (
        .clk(clk),
        .reset(reset),
        .instruction_address(instruction_address),
        .instruction(instruction),
        .data_valid(data_valid),
        .data_write(data_write),
        .data_address(data_address),
        .data_write_data(data_write_data),
        .data_byte_enable(data_byte_enable),
        .data_read_data(data_read_data),
        .halted(halted)
    );

    always #5 clk = ~clk;

    always @* begin
        instruction = instruction_memory[instruction_address[11:2]];
        data_read_data = {
            data_memory[data_address + 32'd3],
            data_memory[data_address + 32'd2],
            data_memory[data_address + 32'd1],
            data_memory[data_address]
        };
    end

    always @(posedge clk) begin
        if (data_valid && data_write) begin
            if (data_byte_enable[0]) data_memory[data_address] = data_write_data[7:0];
            if (data_byte_enable[1]) data_memory[data_address + 1] = data_write_data[15:8];
            if (data_byte_enable[2]) data_memory[data_address + 2] = data_write_data[23:16];
            if (data_byte_enable[3]) data_memory[data_address + 3] = data_write_data[31:24];
        end
    end

    initial begin
        $readmemh("tests/RV32I/basic.hex", instruction_memory, 0, 15);

        for (index = 0; index < MEMORY_BYTES; index = index + 1)
            data_memory[index] = 8'd0;

        clk = 1'b0;
        reset = 1'b1;
        #12;
        reset = 1'b0;

        wait (halted);
        #1;

        $display("");
        $display("========================================");
        $display("RV32I CORE TEST");
        $display("========================================");
        $display("signature[0] = %0d", {data_memory[259], data_memory[258], data_memory[257], data_memory[256]});
        $display("signature[1] = %0d", {data_memory[263], data_memory[262], data_memory[261], data_memory[260]});
        $display("signature[2] = %0d", {data_memory[267], data_memory[266], data_memory[265], data_memory[264]});
        $display("signature[3] = %0d", {data_memory[271], data_memory[270], data_memory[269], data_memory[268]});

        if ({data_memory[259], data_memory[258], data_memory[257], data_memory[256]} !== 32'd12)
            $fatal(1, "ADD result mismatch");
        if ({data_memory[263], data_memory[262], data_memory[261], data_memory[260]} !== 32'd7)
            $fatal(1, "SUB result mismatch");
        if ({data_memory[267], data_memory[266], data_memory[265], data_memory[264]} !== 32'd9)
            $fatal(1, "Branch result mismatch");
        if ({data_memory[271], data_memory[270], data_memory[269], data_memory[268]} !== 32'd48)
            $fatal(1, "Load or shift result mismatch");

        $display("RV32I CORE TEST PASSED");
        $display("");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "RV32I core timeout at PC %h", instruction_address);
    end

endmodule