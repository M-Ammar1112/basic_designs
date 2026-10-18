`timescale 1ns/1ps

module tb_rv32i_coverage;

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
    reg [7:0] data_memory [0:4095];
    integer index;
    integer errors;

    rv32i_core uut (
        .clk(clk), .reset(reset), .instruction_address(instruction_address),
        .instruction(instruction), .data_valid(data_valid), .data_write(data_write),
        .data_address(data_address), .data_write_data(data_write_data),
        .data_byte_enable(data_byte_enable), .data_read_data(data_read_data),
        .halted(halted)
    );

    always #5 clk = ~clk;

    always @* begin
        instruction = instruction_memory[instruction_address[11:2]];
        data_read_data = {
            data_memory[data_address + 3], data_memory[data_address + 2],
            data_memory[data_address + 1], data_memory[data_address]
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

    task check_word;
        input integer address;
        input [31:0] expected;
        reg [31:0] actual;
        begin
            actual = {data_memory[address + 3], data_memory[address + 2], data_memory[address + 1], data_memory[address]};
            $display("signature[%0d] = %h (expected %h)", (address - 512) / 4, actual, expected);
            if (actual !== expected)
                errors = errors + 1;
        end
    endtask

    initial begin
        $readmemh("tests/RV32I/coverage.hex", instruction_memory, 0, 70);
        for (index = 0; index < 4096; index = index + 1)
            data_memory[index] = 8'd0;

        clk = 0;
        reset = 1;
        errors = 0;
        #12 reset = 0;
        wait (halted);
        #1;

        $display("");
        $display("========================================");
        $display("RV32I COVERAGE TEST");
        $display("========================================");
        check_word(512, 32'd291);
        check_word(516, 32'd291);
        check_word(520, 32'hfffffffe);
        check_word(524, 32'd8);
        check_word(528, 32'h00000000);
        check_word(532, 32'hfffffffb);
        check_word(536, 32'hfffffff8);
        check_word(540, 32'd12);
        check_word(544, 32'hfffffffe);
        check_word(548, 32'd1);
        check_word(552, 32'd0);
        check_word(556, 32'd12);
        check_word(560, 32'hfffffffe);
        check_word(564, 32'd1);
        check_word(568, 32'd0);
        check_word(572, 32'd4);
        check_word(576, 32'd11);
        check_word(580, 32'd1);
        check_word(584, 32'd27);
        check_word(588, 32'h00000094);
        check_word(592, 32'hffffff80);
        check_word(596, 32'd128);
        check_word(600, 32'd291);

        if (errors == 0)
            $display("RV32I COVERAGE TEST PASSED");
        else
            $fatal(1, "RV32I coverage test failed with %0d errors", errors);
        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "RV32I coverage timeout at PC %h", instruction_address);
    end

endmodule