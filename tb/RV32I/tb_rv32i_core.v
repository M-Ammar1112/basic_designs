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

    task trace_instruction;
        input [31:0] trace_pc;
        input [31:0] trace_instruction_word;
        reg [6:0] trace_opcode;
        reg [2:0] trace_funct3;
        reg [4:0] trace_rd;
        reg [4:0] trace_rs1;
        reg [4:0] trace_rs2;
        reg signed [31:0] trace_i_immediate;
        reg signed [31:0] trace_s_immediate;
        reg signed [31:0] trace_b_immediate;
        reg signed [31:0] trace_j_immediate;

        begin
            trace_opcode = trace_instruction_word[6:0];
            trace_funct3 = trace_instruction_word[14:12];
            trace_rd = trace_instruction_word[11:7];
            trace_rs1 = trace_instruction_word[19:15];
            trace_rs2 = trace_instruction_word[24:20];
            trace_i_immediate = {{20{trace_instruction_word[31]}}, trace_instruction_word[31:20]};
            trace_s_immediate = {{20{trace_instruction_word[31]}}, trace_instruction_word[31:25], trace_instruction_word[11:7]};
            trace_b_immediate = {{19{trace_instruction_word[31]}}, trace_instruction_word[31], trace_instruction_word[7], trace_instruction_word[30:25], trace_instruction_word[11:8], 1'b0};
            trace_j_immediate = {{11{trace_instruction_word[31]}}, trace_instruction_word[31], trace_instruction_word[19:12], trace_instruction_word[20], trace_instruction_word[30:21], 1'b0};

            $write("PC=%08h  ", trace_pc);

            case (trace_opcode)
                7'b0110111: $display("lui x%0d, 0x%08h", trace_rd, {trace_instruction_word[31:12], 12'd0});
                7'b0010111: $display("auipc x%0d, 0x%08h", trace_rd, {trace_instruction_word[31:12], 12'd0});
                7'b1101111: $display("jal x%0d, %0d", trace_rd, trace_j_immediate);
                7'b1100111: $display("jalr x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                7'b1100011: begin
                    case (trace_funct3)
                        3'b000: $display("beq x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        3'b001: $display("bne x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        3'b100: $display("blt x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        3'b101: $display("bge x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        3'b110: $display("bltu x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        3'b111: $display("bgeu x%0d, x%0d, %0d", trace_rs1, trace_rs2, trace_b_immediate);
                        default: $display(".word 0x%08h", trace_instruction_word);
                    endcase
                end
                7'b0000011: begin
                    case (trace_funct3)
                        3'b000: $display("lb x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                        3'b001: $display("lh x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                        3'b010: $display("lw x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                        3'b100: $display("lbu x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                        3'b101: $display("lhu x%0d, %0d(x%0d)", trace_rd, trace_i_immediate, trace_rs1);
                        default: $display(".word 0x%08h", trace_instruction_word);
                    endcase
                end
                7'b0100011: begin
                    case (trace_funct3)
                        3'b000: $display("sb x%0d, %0d(x%0d)", trace_rs2, trace_s_immediate, trace_rs1);
                        3'b001: $display("sh x%0d, %0d(x%0d)", trace_rs2, trace_s_immediate, trace_rs1);
                        3'b010: $display("sw x%0d, %0d(x%0d)", trace_rs2, trace_s_immediate, trace_rs1);
                        default: $display(".word 0x%08h", trace_instruction_word);
                    endcase
                end
                7'b0010011: begin
                    case (trace_funct3)
                        3'b000: $display("addi x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b010: $display("slti x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b011: $display("sltiu x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b100: $display("xori x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b110: $display("ori x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b111: $display("andi x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_i_immediate);
                        3'b001: $display("slli x%0d, x%0d, %0d", trace_rd, trace_rs1, trace_instruction_word[24:20]);
                        3'b101: $display("%s x%0d, x%0d, %0d", trace_instruction_word[30] ? "srai" : "srli", trace_rd, trace_rs1, trace_instruction_word[24:20]);
                        default: $display(".word 0x%08h", trace_instruction_word);
                    endcase
                end
                7'b0110011: begin
                    case (trace_funct3)
                        3'b000: $display("%s x%0d, x%0d, x%0d", trace_instruction_word[30] ? "sub" : "add", trace_rd, trace_rs1, trace_rs2);
                        3'b001: $display("sll x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        3'b010: $display("slt x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        3'b011: $display("sltu x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        3'b100: $display("xor x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        3'b101: $display("%s x%0d, x%0d, x%0d", trace_instruction_word[30] ? "sra" : "srl", trace_rd, trace_rs1, trace_rs2);
                        3'b110: $display("or x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        3'b111: $display("and x%0d, x%0d, x%0d", trace_rd, trace_rs1, trace_rs2);
                        default: $display(".word 0x%08h", trace_instruction_word);
                    endcase
                end
                7'b0001111: $display("fence");
                7'b1110011: begin
                    if (trace_instruction_word == 32'h00000073)
                        $display("ecall");
                    else if (trace_instruction_word == 32'h00100073)
                        $display("ebreak");
                    else
                        $display("system 0x%08h", trace_instruction_word);
                end
                default: $display(".word 0x%08h", trace_instruction_word);
            endcase
        end
    endtask

    always @(posedge clk) begin
        if (!reset && !halted)
            trace_instruction(instruction_address, instruction);
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