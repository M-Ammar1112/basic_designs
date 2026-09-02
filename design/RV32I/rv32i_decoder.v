module rv32i_decoder (
    input [31:0] instruction,
    output reg reg_write,
    output reg alu_src_immediate,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump,
    output reg jump_register,
    output reg halt,
    output reg [1:0] writeback_select
);

    always @* begin
        reg_write = 1'b0;
        alu_src_immediate = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        jump_register = 1'b0;
        halt = 1'b0;
        writeback_select = 2'd0;

        case (instruction[6:0])
            7'b0110111, 7'b0010111: begin
                reg_write = 1'b1;
                writeback_select = 2'd2;
            end
            7'b1101111: begin
                reg_write = 1'b1;
                jump = 1'b1;
                writeback_select = 2'd1;
            end
            7'b1100111: begin
                reg_write = 1'b1;
                alu_src_immediate = 1'b1;
                jump_register = 1'b1;
                writeback_select = 2'd1;
            end
            7'b1100011: branch = 1'b1;
            7'b0000011: begin
                reg_write = 1'b1;
                alu_src_immediate = 1'b1;
                mem_read = 1'b1;
                writeback_select = 2'd3;
            end
            7'b0100011: begin
                alu_src_immediate = 1'b1;
                mem_write = 1'b1;
            end
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src_immediate = 1'b1;
            end
            7'b0110011: reg_write = 1'b1;
            7'b1110011: halt = (instruction[31:20] == 12'd0) || (instruction[31:20] == 12'd1);
            default: begin
            end
        endcase
    end

endmodule
