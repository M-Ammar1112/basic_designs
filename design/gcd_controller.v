module gcd_controller (
    input  clk,
    input  reset,
    input  start,
    input  equal,
    input  x_greater,
    output reg load,
    output reg subtract_x,
    output reg subtract_y,
    output done
);

    localparam [2:0] IDLE = 3'd0;
    localparam [2:0] LOAD = 3'd1;
    localparam [2:0] COMPARE = 3'd2;
    localparam [2:0] SUBTRACT_X = 3'd3;
    localparam [2:0] SUBTRACT_Y = 3'd4;
    localparam [2:0] FINISH = 3'd5;

    reg [2:0] state;
    reg [2:0] next_state;

    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @* begin
        load = 1'b0;
        subtract_x = 1'b0;
        subtract_y = 1'b0;
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = LOAD;
            end
            LOAD: begin
                load = 1'b1;
                next_state = COMPARE;
            end
            COMPARE: begin
                if (equal)
                    next_state = FINISH;
                else if (x_greater)
                    next_state = SUBTRACT_X;
                else
                    next_state = SUBTRACT_Y;
            end
            SUBTRACT_X: begin
                subtract_x = 1'b1;
                next_state = COMPARE;
            end
            SUBTRACT_Y: begin
                subtract_y = 1'b1;
                next_state = COMPARE;
            end
            FINISH: begin
                if (!start)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    assign done = (state == FINISH);

endmodule