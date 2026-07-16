module reg_bcd (clk, rst, ld, shft, bcd_in, d_adj, bcd_out);

    input clk;
    input rst;
    input ld;
    input shft;
    input [19:0] bcd_in;
    input [19:0] d_adj;
    output [19:0] bcd_out;

    reg [19:0] bcd_out;

    always @(posedge clk) begin
        if (rst) begin
            bcd_out <= 20'd0;
        end else if (ld) begin
            bcd_out <= bcd_in;
        end else if (shft) begin
            bcd_out <= {1'b0, d_adj[19:1]};
        end
    end

endmodule
