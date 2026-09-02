module rv32i_core (
    input         clk,
    input         reset,
    output [31:0] instruction_address,
    input  [31:0] instruction,
    output        data_valid,
    output        data_write,
    output [31:0] data_address,
    output [31:0] data_write_data,
    output [3:0]  data_byte_enable,
    input  [31:0] data_read_data,
    output        halted
);

    wire [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] auipc_result;
    wire [31:0] immediate;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] branch_target;
    wire [31:0] load_data;
    wire [31:0] store_data_shifted;
    wire [31:0] writeback_data;
    wire [31:0] next_pc;
    wire [3:0] byte_enable;
    wire [3:0] alu_control;
    wire [1:0] writeback_select;
    wire reg_write;
    wire alu_src_immediate;
    wire mem_read;
    wire mem_write;
    wire branch;
    wire jump;
    wire jump_register;
    wire branch_taken;
    wire halt_instruction;
    wire [4:0] rd = instruction[11:7];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];

    assign instruction_address = pc;
    assign next_pc = branch_taken ? branch_target : pc_plus4;
    assign halted = halt_instruction;
    assign data_valid = !halt_instruction && (mem_read || mem_write);
    assign data_write = data_valid && mem_write;
    assign data_address = alu_result;
    assign data_write_data = store_data_shifted;
    assign data_byte_enable = data_write ? byte_enable : 4'b0000;
    assign alu_operand_b = alu_src_immediate ? immediate : rs2_data;

    rv32i_pc pc_register (
        .clk(clk), .reset(reset), .enable(!halt_instruction),
        .next_pc(next_pc), .pc(pc)
    );

    rv32i_adder pc_incrementer (
        .a(pc), .b(32'd4), .sum(pc_plus4)
    );

    rv32i_adder auipc_adder (
        .a(pc), .b(immediate), .sum(auipc_result)
    );

    rv32i_immediate_generator immediate_generator (
        .instruction(instruction), .immediate(immediate)
    );

    rv32i_decoder decoder (
        .instruction(instruction), .reg_write(reg_write),
        .alu_src_immediate(alu_src_immediate), .mem_read(mem_read),
        .mem_write(mem_write), .branch(branch), .jump(jump),
        .jump_register(jump_register), .halt(halt_instruction),
        .writeback_select(writeback_select), .alu_control(alu_control)
    );

    register_file register_file (
        .clk(clk), .rs1(rs1), .rs2(rs2),
        .read_data1(rs1_data), .read_data2(rs2_data),
        .reg_write(reg_write && !reset && !halt_instruction),
        .rd(rd), .write_data(writeback_data)
    );

    rv32i_alu alu (
        .a(rs1_data), .b(alu_operand_b),
        .control(alu_control), .result(alu_result)
    );

    rv32i_branch_jump_logic branch_jump_logic (
        .pc(pc), .rs1_data(rs1_data), .immediate(immediate),
        .compare_data(rs2_data), .branch(branch), .jump(jump),
        .jump_register(jump_register), .funct3(instruction[14:12]),
        .target(branch_target), .taken(branch_taken)
    );

    rv32i_load_store_unit load_store_unit (
        .memory_data(data_read_data), .store_data(rs2_data),
        .address(alu_result), .funct3(instruction[14:12]),
        .load_data(load_data), .store_data_shifted(store_data_shifted),
        .byte_enable(byte_enable)
    );

    rv32i_writeback_mux writeback_mux (
        .alu_result(alu_result), .pc_plus4(pc_plus4),
        .upper_immediate((instruction[6:0] == 7'b0010111) ? auipc_result : immediate),
        .load_data(load_data),
        .select(writeback_select), .writeback_data(writeback_data)
    );

endmodule
