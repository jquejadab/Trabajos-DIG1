`timescale 1ns / 1ps

module tb_mult;

    // 1. Declarar señales 
    reg clk;
    reg rst;
    reg init;
    reg [15:0] A;
    reg [15:0] B;
    
    wire [31:0] r;
    wire done;

    // 2. Instanciar el módulo TOP 
    mult uut (
        .clk(clk),
        .rst(rst),
        .init(init),
        .A(A),
        .B(B),
        .r(r),     
        .done(done)
    );

    // 3. Generar el reloj (cambio de estado 5 nanosegundos)
    always #5 clk = ~clk;

    // 4. Bloque inicial para inyectar los estímulos
    initial begin
        
        $dumpfile("simulacion.vcd");
        $dumpvars(0, tb_mult);

        // Estado inicial
        clk = 0;
        rst = 1;
        init = 0;
        A = 0;
        B = 0;

        
        #10 rst = 0;

        // --- PRUEBA 1: Multiplicar 5 * 3 ---
        #10;
        A = 16'd5;
        B = 16'd3;
        init = 1;     // Damos la orden de iniciar
        #10 init = 0; // Bajamos la señal para que no reinicie el proceso
        
        // Esperamos a que el módulo nos avise que terminó
        wait(done == 1);
        $display("Tiempo: %0t | Prueba 1: %d * %d = %d", $time, A, B, r);

        // --- PRUEBA 2: Multiplicar 12 * 12 ---
        #20;
        A = 16'd12;
        B = 16'd12;
        init = 1;
        #10 init = 0;
        
        wait(done == 1);
        $display("Tiempo: %0t | Prueba 2: %d * %d = %d", $time, A, B, r);

        // Terminamos la simulación
        #20 $finish;
    end

endmodule