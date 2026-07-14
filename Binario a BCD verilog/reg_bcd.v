module reg_bcd(clk, reset_bcd, load_bcd, in_a, in_msb, out_BCD);
input clk;
input reset_bcd;
input load_bcd;
input [19:0]in_a;
input in_msb;
output [19:0]out_BCD;

reg [19:0]BCD;

assign out_BCD = BCD;

always @(posedge clk) begin
    if (reset_bcd) begin
        BCD <= 20'd0;
    end else if (load_bcd) begin
        BCD <= {in_a[18:0], in_msb};
    end
end

endmodule
