module counter (clk, rst, init, dec, zero);

    input clk;
    input rst;
    input init;
    input dec;
    output zero;

    reg [4:0] count;

    always @(posedge clk) begin
        if (rst) begin
            count <= 5'd0;
        end else if (init) begin
            count <= 5'd16;
        end else if (dec) begin
            count <= count - 5'd1;
        end
    end

    assign zero = (count == 5'd0);

endmodule
