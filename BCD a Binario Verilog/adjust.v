module adjust (bcd_in, bcd_adj);

    input  [19:0] bcd_in;
    output [19:0] bcd_adj;
    reg [19:0] bcd_adj;

    always @(bcd_in) begin
        
        if (bcd_in[3:0] >= 4'd8) begin
            bcd_adj[3:0] = bcd_in[3:0] - 4'd3;
        end else begin
            bcd_adj[3:0] = bcd_in[3:0];
        end

        if (bcd_in[7:4] >= 4'd8) begin
            bcd_adj[7:4] = bcd_in[7:4] - 4'd3;
        end else begin
            bcd_adj[7:4] = bcd_in[7:4];
        end
        if (bcd_in[11:8] >= 4'd8) begin
            bcd_adj[11:8] = bcd_in[11:8] - 4'd3;
        end else begin
            bcd_adj[11:8] = bcd_in[11:8];
        end
        if (bcd_in[15:12] >= 4'd8) begin
            bcd_adj[15:12] = bcd_in[15:12] - 4'd3;
        end else begin
            bcd_adj[15:12] = bcd_in[15:12];
        end
        if (bcd_in[19:16] >= 4'd8) begin
            bcd_adj[19:16] = bcd_in[19:16] - 4'd3;
        end else begin
            bcd_adj[19:16] = bcd_in[19:16];
        end
        
    end

endmodule
