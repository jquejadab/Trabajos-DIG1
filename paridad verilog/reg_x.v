module reg_x(clk, load_x, shift_x, in_X, out_x0);
input clk;
input load_x;
input shift_x;
input [15:0]in_X;
output out_x0;

reg [15:0]X;

assign out_x0 = X[0];

always @(posedge clk) begin
    if (load_x) begin
        X <= in_X;
    end else if (shift_x) begin
        X <= {1'b0, X[15:1]};
    end
end

endmodule
