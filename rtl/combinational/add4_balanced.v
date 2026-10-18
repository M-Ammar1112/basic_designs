module add4_balanced (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    input  [7:0] d,
    output [9:0] sum
);

    wire [9:0] a_ext;
    wire [9:0] b_ext;
    wire [9:0] c_ext;
    wire [9:0] d_ext;

    wire [9:0] sum_ab;
    wire [9:0] sum_cd;

    assign a_ext = {2'b00, a};
    assign b_ext = {2'b00, b};
    assign c_ext = {2'b00, c};
    assign d_ext = {2'b00, d};

    assign sum_ab = a_ext + b_ext;
    assign sum_cd = c_ext + d_ext;
    assign sum = sum_ab + sum_cd;

endmodule