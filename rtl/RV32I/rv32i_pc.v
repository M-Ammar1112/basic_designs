module rv32i_pc (
    input clk, input reset, input enable, input [31:0] next_pc,
    output reg [31:0] pc
);
    always @(posedge clk) begin
        if (reset) pc <= 32'd0;
        else if (enable) pc <= next_pc;
    end
endmodule