module control_bcd(clk, rst, start, zero, load_b, shift_b, reset_bcd, load_bcd, init_c, decrease_c, done);
input clk;
input rst;
input start;
input zero;
output load_b;
output shift_b;
output reset_bcd;
output load_bcd;
output init_c;
output decrease_c;
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

assign load_b = (current_state == S0);
assign shift_b = (current_state == S2);
assign reset_bcd = (current_state == S0);
assign load_bcd = (current_state == S2);
assign init_c = (current_state == S0);
assign decrease_c = (current_state == S2);
assign done = (current_state == S3);

endmodule
