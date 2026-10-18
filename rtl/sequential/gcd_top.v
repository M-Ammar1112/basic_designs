module gcd_top (
    input        clk,
    input        reset,
    input        start,
    input  [5:0] x_i,
    input  [5:0] y_i,
    output [5:0] gcd,
    output       done
);

    wire [5:0] x_value;
    wire [5:0] y_value;
    wire load;
    wire subtract_x;
    wire subtract_y;

    gcd_controller controller (
        .clk(clk),
        .reset(reset),
        .start(start),
        .equal(x_value == y_value),
        .x_greater(x_value > y_value),
        .load(load),
        .subtract_x(subtract_x),
        .subtract_y(subtract_y),
        .done(done)
    );

    gcd_datapath datapath (
        .clk(clk),
        .reset(reset),
        .load(load),
        .subtract_x(subtract_x),
        .subtract_y(subtract_y),
        .x_i(x_i),
        .y_i(y_i),
        .x_value(x_value),
        .y_value(y_value),
        .gcd(gcd)
    );

endmodule