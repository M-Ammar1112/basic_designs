module rv32i_writeback_mux (
    input [31:0] alu_result, input [31:0] pc_plus4, input [31:0] upper_immediate,
    input [31:0] load_data, input [1:0] select, output reg [31:0] writeback_data
);
    always @* case (select)
        2'd0: writeback_data=alu_result; 2'd1: writeback_data=pc_plus4;
        2'd2: writeback_data=upper_immediate; 2'd3: writeback_data=load_data;
        default: writeback_data=0;
    endcase
endmodule