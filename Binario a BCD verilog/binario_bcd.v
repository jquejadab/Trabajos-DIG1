module binario_bcd(clk, rst, start, B, BCD, done);
input clk;
input rst;
input start;
input [15:0]B;
output [19:0]BCD;
output done;

wire w_load_b;
wire w_shift_b;
wire w_load_bcd;
wire w_reset_bcd;
wire w_init_c;
wire w_decrease_c;
wire w_msb_b;
wire w_zero;

wire [19:0]w_bcd_a;

reg_b reg_b0 (.clk(clk), .load_b(w_load_b), .shift_b(w_shift_b), .in_B(B), .out_msb(w_msb_b));
adjust ajuste0 (.in_BCD(BCD), .out_bcd_a(w_bcd_a));
reg_bcd reg_bcd0 (.clk(clk), .reset_bcd(w_reset_bcd), .load_bcd(w_load_bcd), .in_a(w_bcd_a), .in_msb(w_msb_b), .out_BCD(BCD));
counter count0 (.clk(clk), .init_c(w_init_c), .decrease_c(w_decrease_c), .zero(w_zero));
control_bcd control0 (.clk(clk), .rst(rst), .start(start), .zero(w_zero), .load_b(w_load_b), .shift_b(w_shift_b), .reset_bcd(w_reset_bcd), .load_bcd(w_load_bcd), .init_c(w_init_c), .decrease_c(w_decrease_c), .done(done));

endmodule
