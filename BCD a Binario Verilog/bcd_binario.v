module bcd_binario (clk, rst, start, bcd_in, b_out, done);

    input clk;
    input rst;
    input start;
    input [19:0] bcd_in;
    output [15:0] b_out;
    output done;

    wire ld_bcd;
    wire sh_bcd;
    wire sh_b;
    wire rst_b;
    wire in_c;
    wire dec_c;
    wire z;

    wire [19:0] w_bcd;
    wire [19:0] w_adj;

    control_bcd_bin control_inst (.clk(clk), .rst(rst), .start(start), .zero(z), .ld_bcd(ld_bcd), .sh_bcd(sh_bcd), .sh_b(sh_b), .rst_b(rst_b), .init_c(in_c), .decrease_c(dec_c), .done(done));
    adjust adjust_inst (.bcd_in(w_bcd), .bcd_adj(w_adj));
    reg_bcd reg_bcd_inst (.clk(clk), .rst(rst), .ld(ld_bcd), .shft(sh_bcd), .bcd_in(bcd_in), .d_adj(w_adj), .bcd_out(w_bcd));
    reg_b reg_b_inst (.clk(clk), .rst_b(rst_b), .shft(sh_b), .lsb_adj(w_adj[0]), .b_out(b_out));
    counter counter_inst (.clk(clk), .rst(rst),.init(in_c), .dec(dec_c),.zero(z));

endmodule
