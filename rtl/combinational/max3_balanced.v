module max3_balanced (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    output [7:0] max_out
);

    wire a_ge_b;
    wire a_ge_c;
    wire b_ge_c;

    wire a_is_max;
    wire b_is_max;

    assign a_ge_b = (a >= b);
    assign a_ge_c = (a >= c);
    assign b_ge_c = (b >= c);

    assign a_is_max = a_ge_b && a_ge_c;
    assign b_is_max = (!a_is_max) && b_ge_c;
    assign max_out = a_is_max ? a :
                     b_is_max ? b :
                                c;

endmodule