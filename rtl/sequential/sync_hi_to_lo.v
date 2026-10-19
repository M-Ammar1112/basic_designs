module sync_hi_to_lo #(
    parameter integer WIDTH = 8
) (
    input                 clk_hi,
    input                 clk_lo,
    input                 reset,
    input      [WIDTH-1:0] data_in,
    output     [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] data_hold;
    reg [WIDTH-1:0] data_prev;
    reg             req_toggle;

    reg             req_meta;
    reg             req_sync;
    reg             req_delay;
    reg [WIDTH-1:0] data_out_r;

    reg             rst_hi_meta;
    reg             rst_hi_sync;
    reg             rst_lo_meta;
    reg             rst_lo_sync;

    // Source-domain reset synchronizer (clk_hi)
    always @(posedge clk_hi or posedge reset) begin
        if (reset) begin
            rst_hi_meta <= 1'b1;
            rst_hi_sync <= 1'b1;
        end else begin
            rst_hi_meta <= 1'b0;
            rst_hi_sync <= rst_hi_meta;
        end
    end

    // Destination-domain reset synchronizer (clk_lo)
    always @(posedge clk_lo or posedge reset) begin
        if (reset) begin
            rst_lo_meta <= 1'b1;
            rst_lo_sync <= 1'b1;
        end else begin
            rst_lo_meta <= 1'b0;
            rst_lo_sync <= rst_lo_meta;
        end
    end

    // Source domain (clk_hi): sample data_in and toggle request on change
    always @(posedge clk_hi or posedge rst_hi_sync) begin
        if (rst_hi_sync) begin
            data_hold  <= {WIDTH{1'b0}};
            data_prev  <= {WIDTH{1'b0}};
            req_toggle <= 1'b0;
        end else if (data_in != data_prev) begin
            data_hold  <= data_in;
            data_prev  <= data_in;
            req_toggle <= ~req_toggle;
        end
    end

    // Destination domain (clk_lo): synchronize request toggle and capture stable data
    always @(posedge clk_lo or posedge rst_lo_sync) begin
        if (rst_lo_sync) begin
            req_meta   <= 1'b0;
            req_sync   <= 1'b0;
            req_delay  <= 1'b0;
            data_out_r <= {WIDTH{1'b0}};
        end else begin
            req_meta  <= req_toggle;
            req_sync  <= req_meta;
            req_delay <= req_sync;
            if (req_sync != req_delay)
                data_out_r <= data_hold;
        end
    end

    assign data_out = data_out_r;

endmodule
