module left_shifter_8bit (
    input  [7:0] data_in,
    output [7:0] data_out
);

    assign data_out = {data_in[6:0], 1'b0};

endmodule