module adjust(in_BCD, out_bcd_a);
parameter d = 5;

input [(4*d)-1:0]in_BCD;
output reg [(4*d)-1:0]out_bcd_a;
integer i;

always @(*) begin
    for (i = 0; i < d; i = i + 1) begin
        if (in_BCD[(i*4) +: 4] >= 4'd5) begin
            out_bcd_a[(i*4) +: 4] = in_BCD[(i*4) +: 4] + 4'd3;
        end else begin
            out_bcd_a[(i*4) +: 4] = in_BCD[(i*4) +: 4];
        end
    end
end

endmodule
