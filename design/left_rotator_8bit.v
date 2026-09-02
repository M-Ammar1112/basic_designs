module left_rotator_8bit (
    input  [7:0] data_in,
    output [7:0] data_out
);

    assign data_out = {data_in[6:0], data_in[7]};

endmodule