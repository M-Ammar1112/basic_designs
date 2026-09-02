module add4_cascade (
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

    wire [9:0] sum1;
    wire [9:0] sum2;

    assign a_ext = {2'b00, a};
    assign b_ext = {2'b00, b};
    assign c_ext = {2'b00, c};
    assign d_ext = {2'b00, d};

    assign sum1 = a_ext + b_ext;
    assign sum2 = sum1 + c_ext;
    assign sum = sum2 + d_ext;

endmodule