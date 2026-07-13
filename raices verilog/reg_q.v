module reg_q(clk, rst_dp, shift_Q_1, shift_Q_0, out_Q);
input clk;
input rst_dp;
input shift_Q_1;
input shift_Q_0;
output [7:0]out_Q;

reg [7:0]Q;

assign out_Q = Q;

always @(posedge clk) begin
    if (rst_dp) begin
        Q <= 8'd0;
    end else if (shift_Q_1) begin
        Q <= {Q[6:0], 1'b1};
    end else if (shift_Q_0) begin
        Q <= {Q[6:0], 1'b0};
    end
end

endmodule
