module control_paridad(clk, rst, start, x0, zero, load_x, shift_x, reset_cnt, init_c, decrease_c, inc_cnt, done);
input clk;
input rst;
input start;
input x0;
input zero;
output load_x;
output shift_x;
output reset_cnt;
output init_c;
output decrease_c;
output inc_cnt;
output done;

reg [1:0]current_state;
reg [1:0]next_state;

parameter S0 = 2'd0;
parameter S1 = 2'd1;
parameter S2 = 2'd2;
parameter S3 = 2'd3;

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
            if (zero) next_state = S3;
            else next_state = S2;
        end
        S2: begin
            next_state = S1;
        end
        S3: begin
            next_state = S0;
        end
        default: next_state = S0;
    endcase
end

assign load_x = (current_state == S0);
assign reset_cnt = (current_state == S0);
assign init_c = (current_state == S0);
assign shift_x = (current_state == S2);
assign decrease_c = (current_state == S2);
assign inc_cnt = (current_state == S2) & x0;
assign done = (current_state == S3);

endmodule
