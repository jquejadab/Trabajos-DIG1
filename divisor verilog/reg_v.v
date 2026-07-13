module reg_v(clk,load_v,in_V,out_V);
input clk;
input load_v;
input [15:0] in_V;
output [15:0] out_V;

reg [15:0] out_V;

always @(posedge clk) begin
    if (load_v) begin
        out_V <= in_V;
    end
end

endmodule
