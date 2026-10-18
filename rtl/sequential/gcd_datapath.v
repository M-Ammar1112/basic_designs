module gcd_datapath (
    input         clk,
    input         reset,
    input         load,
    input         subtract_x,
    input         subtract_y,
    input  [5:0]  x_i,
    input  [5:0]  y_i,
    output [5:0]  x_value,
    output [5:0]  y_value,
    output [5:0]  gcd
);

    reg [5:0] x_reg;
    reg [5:0] y_reg;

    always @(posedge clk) begin
        if (reset) begin
            x_reg <= 6'd0;
            y_reg <= 6'd0;
        end else if (load) begin
            x_reg <= x_i;
            y_reg <= y_i;
        end else if (subtract_x) begin
            x_reg <= x_reg - y_reg;
        end else if (subtract_y) begin
            y_reg <= y_reg - x_reg;
        end
    end

    assign x_value = x_reg;
    assign y_value = y_reg;
    assign gcd = x_reg;

endmodule