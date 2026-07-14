module counter(clk, init_c, decrease_c, zero);
input clk;
input init_c;
input decrease_c;
output zero;

reg [4:0]c;

assign zero = (c == 5'd0);

always @(posedge clk) begin
    if (init_c) begin
        c <= 5'd16;
    end else if (decrease_c) begin
        c <= c - 5'd1;
    end
end

endmodule
