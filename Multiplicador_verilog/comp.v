module comp (
    input clk,
    input init_c,
    input dec_c,
    output z
);
    reg [4:0] count;

    always @(posedge clk) begin
        if (init_c)
            count <= 5'd16; // Inicia la cuenta en 16
        else if (dec_c && !z)
            count <= count - 1'b1; // Decrementa en 1
    end

    // La señal z es 1 cuando el contador llega a 0
    assign z = (count == 5'd0);
endmodule