module left_shifter_variable_8bit (
    input  [7:0] data_in,
    input  [2:0] shamt,
    output [7:0] data_out
);

    assign data_out = data_in << shamt;

endmodule