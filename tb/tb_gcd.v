`timescale 1ns/1ps

module tb_gcd;

    reg clk;
    reg reset;
    reg start;
    reg [5:0] x_i;
    reg [5:0] y_i;
    wire [5:0] gcd;
    wire done;
    integer cycles;

    gcd_top uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .x_i(x_i),
        .y_i(y_i),
        .gcd(gcd),
        .done(done)
    );

    always #5 clk = ~clk;

    task check_gcd;
        input [5:0] test_x;
        input [5:0] test_y;
        input [5:0] expected_gcd;
        begin
            @(negedge clk);
            x_i = test_x;
            y_i = test_y;
            start = 1'b1;
            @(negedge clk);
            start = 1'b0;

            cycles = 0;
            while (!done && cycles < 256) begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            if (!done)
                $fatal(1, "GCD(%0d, %0d) timed out", test_x, test_y);
            if (gcd !== expected_gcd)
                $fatal(1, "GCD(%0d, %0d) = %0d, expected %0d",
                       test_x, test_y, gcd, expected_gcd);

            $display("GCD(%0d, %0d) = %0d (completed in %0d cycles)",
                     test_x, test_y, gcd, cycles);
            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("gcd_waveform.vcd");
        $dumpvars(0, tb_gcd);

        clk = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        x_i = 6'd0;
        y_i = 6'd0;

        repeat (2) @(negedge clk);
        reset = 1'b0;

        check_gcd(6'd56, 6'd48, 6'd8);
        check_gcd(6'd24, 6'd24, 6'd24);
        check_gcd(6'd39, 6'd52, 6'd13);

        $display("GCD TEST PASSED");
        $finish;
    end

endmodule