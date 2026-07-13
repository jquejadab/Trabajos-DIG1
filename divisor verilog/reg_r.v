module reg_r(clk, rst, shift_rq, load_r, in_msb_q, alu_out, out_R, sign_r);
input clk;
input rst;
input shift_rq;
input load_r;
input in_msb_q;
input [16:0] alu_out;
output [16:0] out_R;
output sign_r;

reg [16:0] out_R;

assign sign_r = out_R[16];

always @(posedge clk) begin
    if (rst) begin
        out_R <= 17'd0;
    end else if (load_r) begin
        out_R <= alu_out;
    end else if (shift_rq) begin
        out_R <= {out_R[15:0], in_msb_q};
    end
end

endmodule
