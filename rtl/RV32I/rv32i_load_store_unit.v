module rv32i_load_store_unit (
    input [31:0] memory_data, input [31:0] store_data, input [31:0] address,
    input [2:0] funct3, output reg [31:0] load_data,
    output [31:0] store_data_shifted, output [3:0] byte_enable
);
    reg [31:0] shifted_memory_data;
    always @* begin
        shifted_memory_data=memory_data>>(8*address[1:0]);
        case (funct3)
            3'b000: load_data={{24{shifted_memory_data[7]}},shifted_memory_data[7:0]};
            3'b001: load_data={{16{shifted_memory_data[15]}},shifted_memory_data[15:0]};
            3'b010: load_data=memory_data; 3'b100: load_data={24'd0,shifted_memory_data[7:0]};
            3'b101: load_data={16'd0,shifted_memory_data[15:0]}; default: load_data=0;
        endcase
    end
    assign store_data_shifted=store_data<<(8*address[1:0]);
    assign byte_enable=(funct3==3'b000)?(4'b0001<<address[1:0]):
                       (funct3==3'b001)?(4'b0011<<{address[1],1'b0}):4'b1111;
endmodule