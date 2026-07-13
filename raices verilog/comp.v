module comp(in_R, in_T, GE);
input [9:0]in_R;
input [9:0]in_T;
output GE;

assign GE = (in_R >= in_T);

endmodule
