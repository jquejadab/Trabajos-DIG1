module control_div(clk, rst, start, sign_r, z, load_v, load_q, shift_rq, set_q0, force_add, reset, load_r, init_c, dec_c, done);
input clk;
input rst;
input start;
input sign_r;
input z;
output load_v;
output load_q;
output shift_rq;
output set_q0;
output force_add;
output reset;
output load_r;
output init_c;
output dec_c;
output done;

reg load_v;
reg load_q;
reg shift_rq;
reg set_q0;
reg force_add;
reg reset;
reg load_r;
reg init_c;
reg dec_c;
reg done;

reg [2:0] state, next_state;
reg flag_just_operated;

parameter S_START = 3'd0; 
parameter S_INIT = 3'd1;
parameter S_CHECK_C = 3'd2;
parameter S_SHIFT = 3'd3;
parameter S_ADDSUB = 3'd4;
parameter S_END_CHECK = 3'd5;
parameter S_CORRECT = 3'd6;
parameter S_FINISH = 3'd7;

always @(posedge clk) begin
    if (rst) begin
        state <= S_START;
        flag_just_operated <= 1'b0;
    end else begin
        state <= next_state;
        if (state == S_ADDSUB) 
            flag_just_operated <= 1'b1;
        else 
            flag_just_operated <= 1'b0;
    end
end

always @(*) begin
    load_v = 0; load_q = 0; shift_rq = 0; set_q0 = 0; force_add = 0;
    reset = 0; load_r = 0; init_c = 0; dec_c = 0; done = 0;
    next_state = state;

    case (state)
        S_START: begin
            if (start) next_state = S_INIT;
        end
        S_INIT: begin
            load_v = 1;
            load_q = 1;
            reset = 1;
            init_c = 1;
            next_state = S_CHECK_C;
        end
        S_CHECK_C: begin
            if (flag_just_operated && !sign_r) begin
                set_q0 = 1; 
            end
            if (z) next_state = S_END_CHECK;
            else next_state = S_SHIFT;
        end
        S_SHIFT: begin
            shift_rq = 1;
            next_state = S_ADDSUB;
        end
        S_ADDSUB: begin
            load_r = 1;
            dec_c = 1;
            next_state = S_CHECK_C;
        end
        S_END_CHECK: begin
            if (sign_r) next_state = S_CORRECT;
            else next_state = S_FINISH;
        end
        S_CORRECT: begin
            force_add = 1;
            load_r = 1;
            next_state = S_FINISH;
        end
        S_FINISH: begin
            done = 1;
            next_state = S_START;
        end
        default: next_state = S_START;
    endcase
end

endmodule
