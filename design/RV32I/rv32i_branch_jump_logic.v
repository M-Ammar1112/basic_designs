module rv32i_branch_jump_logic (
    input [31:0] pc, input [31:0] rs1_data, input [31:0] immediate,
    input [31:0] compare_data, input branch, input jump, input jump_register,
    input [2:0] funct3, output reg [31:0] target, output reg taken
);
    always @* begin
        target=pc+immediate; taken=jump||jump_register;
        if (branch) case (funct3)
            3'b000: taken=(rs1_data==compare_data); 3'b001: taken=(rs1_data!=compare_data);
            3'b100: taken=($signed(rs1_data)<$signed(compare_data)); 3'b101: taken=($signed(rs1_data)>=$signed(compare_data));
            3'b110: taken=(rs1_data<compare_data); 3'b111: taken=(rs1_data>=compare_data);
            default: taken=0;
        endcase
        if (jump_register) target=(rs1_data+immediate)&32'hfffffffe;
    end
endmodule