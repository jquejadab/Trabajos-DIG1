module control_raices(clk, rst, start, GE, Zero, load_D, reset_dp, init_C, shift_RD, load_R, shift_Q_1, shift_Q_0, decrease_C, done);
input clk;
input rst;
input start;
input GE;
input Zero;
output load_D;
output reset_dp;
output init_C;
output shift_RD;
output load_R;
output shift_Q_1;
output shift_Q_0;
output decrease_C;
output done;

reg [2:0]current_state;
reg [2:0]next_state;

parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;
parameter S6 = 3'd6;
parameter S7 = 3'd7;

always @(posedge clk) begin
    if (rst) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        S0: begin
            if (start) next_state = S1;
            else next_state = S0;
        end
        S1: begin
            next_state = S2;
        end
        S2: begin
            next_state = S3;
        end
        S3: begin
            if (GE) next_state = S4;
            else next_state = S5;
        end
        S4: begin
            next_state = S6;
        end
        S5: begin
            next_state = S6;
        end
        S6: begin
            if (Zero) next_state = S7;
            else next_state = S2;
        end
        S7: begin
            next_state = S0;
        end
        default: next_state = S0;
    endcase
end

assign load_D = (current_state == S1);
assign reset_dp = (current_state == S1);
assign init_C = (current_state == S1);
assign shift_RD = (current_state == S2);
assign load_R = (current_state == S4);
assign shift_Q_1 = (current_state == S4);
assign shift_Q_0 = (current_state == S5);
assign decrease_C = (current_state == S4) | (current_state == S5);
assign done = (current_state == S7);

endmodule
