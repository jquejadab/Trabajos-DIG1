module div(clk,rst,start,D,V,Q,R,done);
input rst;
input clk;
input start;
input [15:0]D;
input [15:0]V;
output[15:0]Q;
output[16:0]R;
output done;

wire w_load_v;
wire w_load_q;
wire w_shift_rq;
wire w_set_q0;
wire w_force_add;
wire w_reset;
wire w_load_r;
wire w_init_c;
wire w_dec_c;
wire w_zero;
wire w_sign_r;
wire w_msb_q;

wire [15:0]w_V;
wire [16:0]w_alu_out;

reg_v reg_v0 (.clk(clk), .load_v(w_load_v), .in_V(V), .out_V(w_V));
reg_q reg_q0 (.clk(clk), .load_q(w_load_q), .shift_rq(w_shift_rq), .set_q0(w_set_q0), .in_D(D), .msb_q(w_msb_q), .out_Q(Q));
reg_r reg_r0 (.clk(clk), .rst(w_reset), .shift_rq(w_shift_rq), .load_r(w_load_r), .in_msb_q(w_msb_q), .alu_out(w_alu_out), .out_R(R), .sign_r(w_sign_r));
alu alu0 (.in_R(R), .in_V(w_V), .force_add(w_force_add), .sign_r(w_sign_r), .alu_out(w_alu_out));
comp comp0 (.clk(clk), .rst(w_reset), .init_c(w_init_c), .dec_c(w_dec_c), .z(w_zero));
control_div control0 (.clk(clk), .rst(rst), .start(start), .sign_r(w_sign_r), .z(w_zero), .load_v(w_load_v), .load_q(w_load_q), .shift_rq(w_shift_rq), .set_q0(w_set_q0), .force_add(w_force_add), .reset(w_reset), .load_r(w_load_r), .init_c(w_init_c), .dec_c(w_dec_c), .done(done));

endmodule
