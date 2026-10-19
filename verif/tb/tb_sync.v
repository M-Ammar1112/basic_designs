`timescale 1ns/1ps

module tb_sync;

    localparam integer WIDTH = 8;

    reg                clk_hi;
    reg                clk_lo;
    reg                reset;

    reg  [WIDTH-1:0]   hi_data;
    reg  [WIDTH-1:0]   lo_data;

    wire [WIDTH-1:0]   hi_to_lo_out;
    wire [WIDTH-1:0]   lo_to_hi_out;

    sync_hi_to_lo #(.WIDTH(WIDTH)) u_hi_to_lo (
        .clk_hi  (clk_hi),
        .clk_lo  (clk_lo),
        .reset   (reset),
        .data_in (hi_data),
        .data_out(hi_to_lo_out)
    );

    sync_lo_to_hi #(.WIDTH(WIDTH)) u_lo_to_hi (
        .clk_lo  (clk_lo),
        .clk_hi  (clk_hi),
        .reset   (reset),
        .data_in (lo_data),
        .data_out(lo_to_hi_out)
    );

    always #5  clk_hi = ~clk_hi;
    always #20 clk_lo = ~clk_lo;

    task check_hi_to_lo;
        input [WIDTH-1:0] value;
        begin
            @(negedge clk_hi);
            hi_data = value;
            repeat (8) @(posedge clk_lo);
            if (hi_to_lo_out !== value)
                $fatal(1, "hi->lo: expected %02h, got %02h", value, hi_to_lo_out);
            $display("hi->lo: %02h synchronized (coherent toggle) OK", value);
        end
    endtask

    task check_lo_to_hi;
        input [WIDTH-1:0] value;
        begin
            @(negedge clk_lo);
            lo_data = value;
            repeat (16) @(posedge clk_hi);
            if (lo_to_hi_out !== value)
                $fatal(1, "lo->hi: expected %02h, got %02h", value, lo_to_hi_out);
            $display("lo->hi: %02h synchronized (coherent toggle) OK", value);
        end
    endtask

    initial begin
        $dumpfile("sync_waveform.vcd");
        $dumpvars(0, tb_sync);

        clk_hi  = 1'b0;
        clk_lo  = 1'b0;
        reset   = 1'b1;
        hi_data = {WIDTH{1'b0}};
        lo_data = {WIDTH{1'b0}};

        repeat (4) @(negedge clk_lo);
        reset = 1'b0;
        repeat (4) @(negedge clk_lo);

        check_hi_to_lo(8'hA5);
        check_hi_to_lo(8'h3C);
        check_hi_to_lo(8'hFF);

        check_lo_to_hi(8'h5A);
        check_lo_to_hi(8'hC3);
        check_lo_to_hi(8'h01);

        check_hi_to_lo(8'h12);
        check_lo_to_hi(8'h34);

        $display("SYNC TEST PASSED");
        $finish;
    end

endmodule
