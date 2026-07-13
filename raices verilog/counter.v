module counter(clk, init_C, decrease_C, Zero);
input clk;
input init_C;
input decrease_C;
output Zero;

reg [3:0]C;

assign Zero = (C == 4'd0);

always @(posedge clk) begin
    if (init_C) begin
        C <= 4'd8;
    end else if (decrease_C) begin
        C <= C - 4'd1;
    end
end

endmodule
