module rv32i_core (
    input         clk,
    input         reset,
    output [31:0]  instruction_address,
    input  [31:0]  instruction,
    output         data_valid,
    output         data_write,
    output [31:0]  data_address,
    output [31:0]  data_write_data,
    output [3:0]   data_byte_enable,
    input  [31:0]  data_read_data,
    output         halted
);

    localparam [6:0] OPCODE_LUI    = 7'b0110111;
    localparam [6:0] OPCODE_AUIPC  = 7'b0010111;
    localparam [6:0] OPCODE_JAL    = 7'b1101111;
    localparam [6:0] OPCODE_JALR   = 7'b1100111;
    localparam [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam [6:0] OPCODE_STORE  = 7'b0100011;
    localparam [6:0] OPCODE_IMM    = 7'b0010011;
    localparam [6:0] OPCODE_REG    = 7'b0110011;
    localparam [6:0] OPCODE_MISC   = 7'b0001111;
    localparam [6:0] OPCODE_SYSTEM = 7'b1110011;

    reg [31:0] pc;
    reg halted_reg;

    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    reg reg_write;
    reg [31:0] write_data;

    reg [31:0] next_pc;
    reg [31:0] immediate;
    reg [31:0] effective_address;
    reg [31:0] load_data;
    reg branch_taken;
    reg [31:0] alu_result;
    reg [31:0] shifted_load_data;
    reg [7:0] load_byte;
    reg [15:0] load_half;

    assign instruction_address = pc;
    assign halted = halted_reg;
    assign data_valid = !halted_reg && ((opcode == OPCODE_LOAD) || (opcode == OPCODE_STORE));
    assign data_write = data_valid && (opcode == OPCODE_STORE);
    assign data_address = effective_address;
    assign data_write_data = read_data2 << (8 * effective_address[1:0]);
    assign data_byte_enable = (opcode != OPCODE_STORE) ? 4'b0000 :
                              (funct3 == 3'b000) ? (4'b0001 << effective_address[1:0]) :
                              (funct3 == 3'b001) ? (4'b0011 << {effective_address[1], 1'b0}) :
                                                   4'b1111;

    register_file registers (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .reg_write(reg_write && !reset && !halted_reg),
        .rd(rd),
        .write_data(write_data)
    );

    function [31:0] arithmetic_right_shift;
        input [31:0] value;
        input [4:0] amount;
        begin
            arithmetic_right_shift = (value >> amount) | ({32{value[31]}} << (32 - amount));
        end
    endfunction

    always @* begin
        next_pc = pc + 32'd4;
        immediate = 32'd0;
        effective_address = read_data1;
        load_data = data_read_data;
        shifted_load_data = data_read_data >> (8 * effective_address[1:0]);
        load_byte = shifted_load_data[7:0];
        load_half = shifted_load_data[15:0];
        branch_taken = 1'b0;
        alu_result = 32'd0;
        reg_write = 1'b0;
        write_data = 32'd0;

        case (opcode)
            OPCODE_LUI: begin
                write_data = {instruction[31:12], 12'd0};
                reg_write = 1'b1;
            end
            OPCODE_AUIPC: begin
                write_data = pc + {instruction[31:12], 12'd0};
                reg_write = 1'b1;
            end
            OPCODE_JAL: begin
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                next_pc = pc + immediate;
                write_data = pc + 32'd4;
                reg_write = 1'b1;
            end
            OPCODE_JALR: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                next_pc = (read_data1 + immediate) & 32'hfffffffe;
                write_data = pc + 32'd4;
                reg_write = 1'b1;
            end
            OPCODE_BRANCH: begin
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                case (funct3)
                    3'b000: branch_taken = (read_data1 == read_data2);
                    3'b001: branch_taken = (read_data1 != read_data2);
                    3'b100: branch_taken = ($signed(read_data1) < $signed(read_data2));
                    3'b101: branch_taken = ($signed(read_data1) >= $signed(read_data2));
                    3'b110: branch_taken = (read_data1 < read_data2);
                    3'b111: branch_taken = (read_data1 >= read_data2);
                    default: branch_taken = 1'b0;
                endcase
                if (branch_taken)
                    next_pc = pc + immediate;
            end
            OPCODE_LOAD: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                effective_address = read_data1 + immediate;
                case (funct3)
                    3'b000: write_data = {{24{load_byte[7]}}, load_byte};
                    3'b001: write_data = {{16{load_half[15]}}, load_half};
                    3'b010: write_data = load_data;
                    3'b100: write_data = {24'd0, load_byte};
                    3'b101: write_data = {16'd0, load_half};
                    default: write_data = 32'd0;
                endcase
                reg_write = 1'b1;
            end
            OPCODE_STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                effective_address = read_data1 + immediate;
            end
            OPCODE_IMM: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
                case (funct3)
                    3'b000: alu_result = read_data1 + immediate;
                    3'b010: alu_result = ($signed(read_data1) < $signed(immediate));
                    3'b011: alu_result = (read_data1 < immediate);
                    3'b100: alu_result = read_data1 ^ immediate;
                    3'b110: alu_result = read_data1 | immediate;
                    3'b111: alu_result = read_data1 & immediate;
                    3'b001: alu_result = read_data1 << instruction[24:20];
                    3'b101: alu_result = instruction[30] ? arithmetic_right_shift(read_data1, instruction[24:20]) : (read_data1 >> instruction[24:20]);
                    default: alu_result = 32'd0;
                endcase
                write_data = alu_result;
                reg_write = 1'b1;
            end
            OPCODE_REG: begin
                case (funct3)
                    3'b000: alu_result = funct7[5] ? (read_data1 - read_data2) : (read_data1 + read_data2);
                    3'b001: alu_result = read_data1 << read_data2[4:0];
                    3'b010: alu_result = ($signed(read_data1) < $signed(read_data2));
                    3'b011: alu_result = (read_data1 < read_data2);
                    3'b100: alu_result = read_data1 ^ read_data2;
                    3'b101: alu_result = funct7[5] ? arithmetic_right_shift(read_data1, read_data2[4:0]) : (read_data1 >> read_data2[4:0]);
                    3'b110: alu_result = read_data1 | read_data2;
                    3'b111: alu_result = read_data1 & read_data2;
                    default: alu_result = 32'd0;
                endcase
                write_data = alu_result;
                reg_write = 1'b1;
            end
            OPCODE_SYSTEM: begin
                if ((instruction[31:20] == 12'd0) || (instruction[31:20] == 12'd1))
                    next_pc = pc;
            end
            default: begin
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'd0;
            halted_reg <= 1'b0;
        end
        else if (!halted_reg) begin
            pc <= next_pc;
            if ((opcode == OPCODE_SYSTEM) && ((instruction[31:20] == 12'd0) || (instruction[31:20] == 12'd1)))
                halted_reg <= 1'b1;
        end
    end

endmodule