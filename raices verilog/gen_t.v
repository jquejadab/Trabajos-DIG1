module gen_t(in_Q, out_T);
input [7:0]in_Q;
output [9:0]out_T;

assign out_T = {in_Q, 2'b01};

endmodule
