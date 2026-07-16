module reg_b (clk, rst_b, shft, lsb_adj, b_out);

    input clk;
    input rst_b;
    input shft;
    input lsb_adj;
    output [15:0] b_out;

    reg [15:0] b_out;

    always @(posedge clk) begin
        if (rst_b) begin
            b_out <= 16'd0;
        end else if (shft) begin
            b_out <= {lsb_adj, b_out[15:1]};
        end
    end

endmodule
