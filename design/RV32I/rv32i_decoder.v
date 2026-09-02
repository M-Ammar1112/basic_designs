module rv32i_decoder (
    input [31:0] instruction,
    output reg reg_write, output reg alu_src_immediate,
    output reg mem_read, output reg mem_write,
    output reg branch, output reg jump, output reg jump_register,
    output reg halt, output reg [1:0] writeback_select,
    output reg [3:0] alu_control
);
    localparam [3:0] ALU_ADD=4'd0, ALU_SUB=4'd1, ALU_SLL=4'd2, ALU_SLT=4'd3, ALU_SLTU=4'd4;
    localparam [3:0] ALU_XOR=4'd5, ALU_SRL=4'd6, ALU_SRA=4'd7, ALU_OR=4'd8, ALU_AND=4'd9;
    always @* begin
        reg_write=0; alu_src_immediate=0; mem_read=0; mem_write=0; branch=0; jump=0; jump_register=0; halt=0;
        writeback_select=0; alu_control=ALU_ADD;
        case (instruction[6:0])
            7'b0110111, 7'b0010111: begin reg_write=1; writeback_select=2; end
            7'b1101111: begin reg_write=1; jump=1; writeback_select=1; end
            7'b1100111: begin reg_write=1; jump_register=1; alu_src_immediate=1; writeback_select=1; end
            7'b1100011: branch=1;
            7'b0000011: begin reg_write=1; alu_src_immediate=1; mem_read=1; writeback_select=3; end
            7'b0100011: begin alu_src_immediate=1; mem_write=1; end
            7'b0010011: begin
                reg_write=1; alu_src_immediate=1;
                case (instruction[14:12])
                    3'b000: alu_control=ALU_ADD; 3'b010: alu_control=ALU_SLT;
                    3'b011: alu_control=ALU_SLTU; 3'b100: alu_control=ALU_XOR;
                    3'b110: alu_control=ALU_OR; 3'b111: alu_control=ALU_AND;
                    3'b001: alu_control=ALU_SLL; 3'b101: alu_control=instruction[30] ? ALU_SRA : ALU_SRL;
                    default: alu_control=ALU_ADD;
                endcase
            end
            7'b0110011: begin
                reg_write=1;
                case (instruction[14:12])
                    3'b000: alu_control=instruction[30] ? ALU_SUB : ALU_ADD;
                    3'b001: alu_control=ALU_SLL; 3'b010: alu_control=ALU_SLT;
                    3'b011: alu_control=ALU_SLTU; 3'b100: alu_control=ALU_XOR;
                    3'b101: alu_control=instruction[30] ? ALU_SRA : ALU_SRL;
                    3'b110: alu_control=ALU_OR; 3'b111: alu_control=ALU_AND;
                    default: alu_control=ALU_ADD;
                endcase
            end
            7'b1110011: halt=(instruction[31:20] == 12'd0) || (instruction[31:20] == 12'd1);
            default: begin end
        endcase
    end
endmodule