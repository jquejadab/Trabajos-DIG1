module paridad(clk, rst, start, X, Counter, Paridad, done);
input clk;
input rst;
input start;
input [15:0]X;
output [4:0]Counter;
output Paridad;
output done;

wire w_load_x;
wire w_shift_x;
wire w_reset_cnt;
wire w_inc_cnt;
wire w_init_c;
wire w_decrease_c;
wire w_x0;
wire w_zero;

reg_x reg_x0 (.clk(clk), .load_x(w_load_x), .shift_x(w_shift_x), .in_X(X), .out_x0(w_x0));
reg_counter reg_cnt0 (.clk(clk), .reset_cnt(w_reset_cnt), .inc_cnt(w_inc_cnt), .out_counter(Counter), .out_paridad(Paridad));
counter count0 (.clk(clk), .init_c(w_init_c), .decrease_c(w_decrease_c), .zero(w_zero));
control_paridad control0 (.clk(clk), .rst(rst), .start(start), .x0(w_x0), .zero(w_zero), .load_x(w_load_x), .shift_x(w_shift_x), .reset_cnt(w_reset_cnt), .init_c(w_init_c), .decrease_c(w_decrease_c), .inc_cnt(w_inc_cnt), .done(done));

endmodule
