module reg_d(clk, load_D, shift_RD, in_N, out_2msb);
input clk;
input load_D;
input shift_RD;
input [15:0]in_N;
output [1:0]out_2msb;

reg [15:0]D;

assign out_2msb = D[15:14];

always @(posedge clk) begin
    if (load_D) begin
        D <= in_N;
    end else if (shift_RD) begin
        D <= {D[13:0], 2'b00};
    end
end

endmodule