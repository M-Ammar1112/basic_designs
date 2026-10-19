module sync_hi_to_lo #(
    parameter integer WIDTH = 8
) (
    input                 clk_hi,
    input                 clk_lo,
    input                 reset,
    input      [WIDTH-1:0] data_in,
    output     [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] sync_meta;
    reg [WIDTH-1:0] sync_out;

    always @(posedge clk_lo or posedge reset) begin
        if (reset) begin
            sync_meta <= {WIDTH{1'b0}};
            sync_out  <= {WIDTH{1'b0}};
        end else begin
            sync_meta <= data_in;
            sync_out  <= sync_meta;
        end
    end

    assign data_out = sync_out;

endmodule
