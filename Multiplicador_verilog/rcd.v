module rcd (clk, in_B, shift, load, s_B);
input clk;
input [15:0]in_B;
input load;
input shift;
output reg [15:0]s_B;

always @(posedge clk) begin
    if (load) begin
        s_B = in_B; 
    end else if (shift) begin
        s_B <= {1'b0, s_B[15:1]}; // Shift left by 1 bit, filling with 0
    end
end

endmodule
