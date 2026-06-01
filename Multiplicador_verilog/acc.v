module acc (
    input clk,
    input [31:0] A,
    input add,
    input rst, // Se conecta a w_load para limpiar al inicio
    output reg [31:0] r
);
    always @(posedge clk) begin
        if (rst)
            r <= 32'b0; // Limpia el acumulador
        else if (add)
            r <= r + A; // Suma el valor desplazado de A
    end
endmodule