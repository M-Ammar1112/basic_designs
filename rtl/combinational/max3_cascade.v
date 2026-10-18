module max3_cascade (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    output [7:0] max_out
);

    wire [7:0] max_ab;

    assign max_ab = (a >= b) ? a : b;
    assign max_out = (max_ab >= c) ? max_ab : c;

endmodule