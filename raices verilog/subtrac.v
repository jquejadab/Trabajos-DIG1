module subtrac(in_R, in_T, out_sub);
input [9:0]in_R;
input [9:0]in_T;
output [9:0]out_sub;

assign out_sub = in_R - in_T;

endmodule
