module reg_q(clk, load_q, shift_rq, set_q0, in_D, msb_q, out_Q);
input clk;
input load_q;
input shift_rq;
input set_q0;
input [15:0] in_D;
output msb_q;
output [15:0] out_Q;

reg [15:0] out_Q;

assign msb_q = out_Q[15];

always @(posedge clk) begin
    if (load_q) begin
        out_Q <= in_D;
    end else if (shift_rq) begin
        out_Q <= {out_Q[14:0], 1'b0};
    end else if (set_q0) begin
        out_Q[0] <= 1'b1;
    end
end

endmodule
