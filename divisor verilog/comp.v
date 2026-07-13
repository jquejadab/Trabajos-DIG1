module comp(clk, rst, init_c, dec_c, z);
input clk;
input rst;
input init_c;
input dec_c;
output z;

reg [4:0] count;

assign z = (count == 5'd0);

always @(posedge clk) begin
    if (init_c) begin
        count <= 5'd16;
    end else if (rst) begin
        count <= 5'd0;
    end else if (dec_c) begin
        count <= count - 5'd1;
    end
end

endmodule
