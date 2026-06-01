module rci (
    input clk,
    input [15:0] in_A,
    input shift,
    input load,
    output reg [31:0] s_A
);
    always @(posedge clk) begin
        if (load)
            s_A <= {16'b0, in_A};
        else if (shift)
            s_A <= {s_A[30:0], 1'b0}; // Desplaza a la izquierda
    end
endmodule