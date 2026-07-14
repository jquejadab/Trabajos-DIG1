module reg_counter(clk, reset_cnt, inc_cnt, out_counter, out_paridad);
input clk;
input reset_cnt;
input inc_cnt;
output [4:0]out_counter;
output out_paridad;

reg [4:0]count;

assign out_counter = count;
assign out_paridad = count[0];

always @(posedge clk) begin
    if (reset_cnt) begin
        count <= 5'd0;
    end else if (inc_cnt) begin
        count <= count + 5'd1;
    end
end

endmodule
