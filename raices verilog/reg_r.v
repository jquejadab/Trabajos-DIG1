module reg_r(clk, rst_dp, load_R, shift_RD, in_2msb, in_sub, out_R);
input clk;
input rst_dp;
input load_R;
input shift_RD;
input [1:0]in_2msb;
input [9:0]in_sub;
output [9:0]out_R;

reg [9:0]R;

assign out_R = R;

always @(posedge clk) begin
    if (rst_dp) begin
        R <= 10'd0;
    end else if (load_R) begin
        R <= in_sub;
    end else if (shift_RD) begin
        R <= {R[7:0], in_2msb};
    end
end

endmodule