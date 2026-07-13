module alu(in_R, in_V, force_add, sign_r, alu_out);
input [16:0] in_R;
input [15:0] in_V;
input force_add;
input sign_r;
output [16:0] alu_out;

wire [16:0] ext_V;

assign ext_V = {1'b0, in_V};
assign alu_out = (force_add | sign_r) ? (in_R + ext_V) : (in_R - ext_V);

endmodule
