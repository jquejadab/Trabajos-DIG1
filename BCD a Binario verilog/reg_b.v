module reg_b(clk, load_b, shift_b, in_B, out_msb);
input clk;
input load_b;
input shift_b;
input [15:0]in_B;
output out_msb;

reg [15:0]B;

assign out_msb = B[15];

always @(posedge clk) begin
    if (load_b) begin
        B <= in_B;
    end else if (shift_b) begin
        B <= {B[14:0], 1'b0};
    end
end

endmodule
