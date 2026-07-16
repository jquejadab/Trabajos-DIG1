module control_bcd_bin (
    clk, rst, start, zero,
    ld_bcd, sh_bcd, rst_b, sh_b, init_c, decrease_c, done
);

    input clk;
    input rst;
    input start;
    input zero;

    output ld_bcd;
    output sh_bcd;
    output rst_b;
    output sh_b;
    output init_c;
    output decrease_c;
    output done;

    parameter START   = 2'd0;
    parameter CHECK   = 2'd1;
    parameter PROCESS = 2'd2;
    parameter FINISH  = 2'd3;

    reg [1:0] current_state;
    reg [1:0] next_state;

    // 1. Memoria de estado
    always @(posedge clk) begin
        if (rst) begin
            current_state <= START;
        end else begin
            current_state <= next_state;
        end
    end

    always @(current_state or start or zero) begin
        case (current_state)
            START: begin
                if (start) next_state = CHECK; 
                else next_state = START;
            end
            CHECK: begin
                if (zero) next_state = FINISH; 
                else next_state = PROCESS;
            end
            PROCESS: begin
                next_state = CHECK;
            end
            FINISH: begin
                if (start) next_state = START; 
                else next_state = FINISH; 
            end
            default: next_state = START;
        endcase
    end

    assign ld_bcd = (current_state == START);
    assign rst_b = (current_state == START);
    assign init_c = (current_state == START);
    assign sh_bcd = (current_state == PROCESS);
    assign sh_b = (current_state == PROCESS);
    assign decrease_c = (current_state == PROCESS);
    assign done = (current_state == FINISH);

endmodule
