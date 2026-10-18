module left_rotator_variable (
    input  [7:0] data_in,
    input  [2:0] shamt,
    output [7:0] data_out
);

    assign data_out = (data_in << shamt) | (data_in >> (8 - shamt));

endmodule