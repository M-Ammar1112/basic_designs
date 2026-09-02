`timescale 1ns/1ps

module tb_compare;

    reg [7:0] a;
    reg [7:0] b;
    reg [7:0] c;
    reg [7:0] d;

    wire [9:0] sum_cascade;
    wire [9:0] sum_balanced;

    wire [7:0] max_cascade;
    wire [7:0] max_balanced;

    wire [7:0] shifted;
    wire [7:0] rotated;

    reg [9:0] expected_sum;
    reg [7:0] expected_max;

    integer i;
    integer errors;


    // ------------------------------------
    // Instantiate four-number cascaded adder
    // ------------------------------------

    add4_cascade uut_add_cascade (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sum(sum_cascade)
    );


    // ------------------------------------
    // Instantiate four-number balanced adder
    // ------------------------------------

    add4_balanced uut_add_balanced (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sum(sum_balanced)
    );


    // ------------------------------------
    // Instantiate cascaded maximum circuit
    // ------------------------------------

    max3_cascade uut_max_cascade (
        .a(a),
        .b(b),
        .c(c),
        .max_out(max_cascade)
    );


    // ------------------------------------
    // Instantiate balanced maximum circuit
    // ------------------------------------

    max3_balanced uut_max_balanced (
        .a(a),
        .b(b),
        .c(c),
        .max_out(max_balanced)
    );


    left_shifter_8bit uut_left_shifter (
        .data_in(a),
        .data_out(shifted)
    );


    left_rotator_8bit uut_left_rotator (
        .data_in(a),
        .data_out(rotated)
    );


    // ------------------------------------
    // Reference function for maximum
    // ------------------------------------

    function [7:0] calculate_max;

        input [7:0] x;
        input [7:0] y;
        input [7:0] z;

        begin

            if ((x >= y) && (x >= z))
                calculate_max = x;

            else if (y >= z)
                calculate_max = y;

            else
                calculate_max = z;

        end

    endfunction


    // ------------------------------------
    // Test procedure
    // ------------------------------------

    initial begin
        
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_compare);

        errors = 0;

        $display("");
        $display("========================================");
        $display(" RTL COMPARISON TEST");
        $display("========================================");


        // ====================================
        // TEST 1
        // ====================================

        a = 8'd10;
        b = 8'd20;
        c = 8'd30;
        d = 8'd40;

        #1;

        expected_sum =
              {2'b00, a}
            + {2'b00, b}
            + {2'b00, c}
            + {2'b00, d};

        expected_max = calculate_max(a, b, c);

        $display("");
        $display("TEST 1");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("C = %0d", c);
        $display("D = %0d", d);

        $display("Expected Sum  = %0d", expected_sum);
        $display("Cascade Sum   = %0d", sum_cascade);
        $display("Balanced Sum  = %0d", sum_balanced);

        $display("Expected Max  = %0d", expected_max);
        $display("Cascade Max   = %0d", max_cascade);
        $display("Balanced Max  = %0d", max_balanced);


        if (sum_cascade !== expected_sum)
            errors = errors + 1;

        if (sum_balanced !== expected_sum)
            errors = errors + 1;

        if (max_cascade !== expected_max)
            errors = errors + 1;

        if (max_balanced !== expected_max)
            errors = errors + 1;


        // ====================================
        // TEST 2 - Maximum values
        // ====================================

        a = 8'd255;
        b = 8'd255;
        c = 8'd255;
        d = 8'd255;

        #1;

        expected_sum =
              {2'b00, a}
            + {2'b00, b}
            + {2'b00, c}
            + {2'b00, d};

        expected_max = calculate_max(a, b, c);

        $display("");
        $display("TEST 2");
        $display("Inputs = 255, 255, 255, 255");
        $display("Expected Sum  = %0d", expected_sum);
        $display("Cascade Sum   = %0d", sum_cascade);
        $display("Balanced Sum  = %0d", sum_balanced);
        $display("Expected Max  = %0d", expected_max);
        $display("Cascade Max   = %0d", max_cascade);
        $display("Balanced Max  = %0d", max_balanced);


        if (sum_cascade !== expected_sum)
            errors = errors + 1;

        if (sum_balanced !== expected_sum)
            errors = errors + 1;

        if (max_cascade !== expected_max)
            errors = errors + 1;

        if (max_balanced !== expected_max)
            errors = errors + 1;


        // ====================================
        // RANDOM TESTS
        // ====================================

        $display("");
        $display("Running 5000 random tests...");

        for (i = 0; i < 5000; i = i + 1) begin

            a = $random;
            b = $random;
            c = $random;
            d = $random;

            #1;

            expected_sum =
                  {2'b00, a}
                + {2'b00, b}
                + {2'b00, c}
                + {2'b00, d};

            expected_max = calculate_max(a, b, c);


            // Check cascaded adder
            if (sum_cascade !== expected_sum) begin

                $display(
                    "Cascade ADD error: A=%0d B=%0d C=%0d D=%0d",
                    a, b, c, d
                );

                errors = errors + 1;

            end


            // Check balanced adder
            if (sum_balanced !== expected_sum) begin

                $display(
                    "Balanced ADD error: A=%0d B=%0d C=%0d D=%0d",
                    a, b, c, d
                );

                errors = errors + 1;

            end


            // Check both adder implementations agree
            if (sum_cascade !== sum_balanced) begin

                $display("Adder implementations disagree.");

                errors = errors + 1;

            end


            // Check cascaded max
            if (max_cascade !== expected_max) begin

                $display(
                    "Cascade MAX error: A=%0d B=%0d C=%0d",
                    a, b, c
                );

                errors = errors + 1;

            end


            // Check balanced max
            if (max_balanced !== expected_max) begin

                $display(
                    "Balanced MAX error: A=%0d B=%0d C=%0d",
                    a, b, c
                );

                errors = errors + 1;

            end


            // Check both max implementations agree
            if (max_cascade !== max_balanced) begin

                $display("MAX implementations disagree.");

                errors = errors + 1;

            end


            // Check left shift and left rotation
            if (shifted !== {a[6:0], 1'b0}) begin

                $display("Left shift error: A=%0d", a);

                errors = errors + 1;

            end

            if (rotated !== {a[6:0], a[7]}) begin

                $display("Left rotation error: A=%0d", a);

                errors = errors + 1;

            end

        end


        // ====================================
        // FINAL RESULT
        // ====================================

        $display("");
        $display("========================================");

        if (errors == 0) begin

            $display("ALL TESTS PASSED");

        end
        else begin

            $display("TEST FAILED");
            $display("TOTAL ERRORS = %0d", errors);

        end

        $display("========================================");
        $display("");

        $finish;

    end

endmodule