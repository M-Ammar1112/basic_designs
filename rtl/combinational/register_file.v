module register_file (
    input         clk,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    output [31:0] read_data1,
    output [31:0] read_data2,
    input         reg_write,
    input  [4:0]  rd,
    input  [31:0] write_data
);

    reg [31:0] registers [0:31];

    always @(posedge clk) begin
        if (reg_write && (rd != 5'd0))
            registers[rd] <= write_data;
    end

    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

endmodule