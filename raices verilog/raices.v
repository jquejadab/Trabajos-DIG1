module raices(clk, rst, start, N, Q, R, done);
input clk;
input rst;
input start;
input [15:0] N;
output [7:0] Q;
output [9:0] R;
output done;

wire w_load_D;
wire w_reset_dp; // Señal "Reset" del diagrama para limpiar registros
wire w_init_C;
wire w_shift_RD;
wire w_load_R;
wire w_shift_Q_1;
wire w_shift_Q_0;
wire w_decrease_C;

wire w_Zero;
wire w_GE;       
wire [9:0] w_sub_out;
wire [9:0] w_T;      
wire [1:0] w_2msb_D;  

reg_d reg_d0 (.clk(clk), .load_D(w_load_D), .shift_RD(w_shift_RD), .in_N(N), .out_2msb(w_2msb_D));

reg_r reg_r0 (.clk(clk), .rst_dp(w_reset_dp), .load_R(w_load_R), .shift_RD(w_shift_RD), .in_2msb(w_2msb_D), .in_sub(w_sub_out), .out_R(R));

reg_q reg_q0 (.clk(clk), .rst_dp(w_reset_dp), .shift_Q_1(w_shift_Q_1), .shift_Q_0(w_shift_Q_0), .out_Q(Q));

gen_t gen_t0 (.in_Q(Q), .out_T(w_T));

subtrac sub0 (.in_R(R), .in_T(w_T), .out_sub(w_sub_out));

comp comp0 (.in_R(R), .in_T(w_T), .GE(w_GE));

counter count0 (.clk(clk), .init_C(w_init_C), .decrease_C(w_decrease_C), .Zero(w_Zero));

control_raices control0 (.clk(clk), .rst(rst), .start(start), .GE(w_GE), .Zero(w_Zero), .load_D(w_load_D), .reset_dp(w_reset_dp), .init_C(w_init_C), .shift_RD(w_shift_RD), .load_R(w_load_R), .shift_Q_1(w_shift_Q_1), .shift_Q_0(w_shift_Q_0), .decrease_C(w_decrease_C), .done(done));

endmodule
