module div_tb;

    // Entradas al top module
    reg clk;
    reg rst;
    reg start;
    reg [15:0] D;
    reg [15:0] V;

    // Salidas del top module
    wire [15:0] Q;
    wire [16:0] R;
    wire done;

    // Instancia del nuevo top module
    div uut (
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .D(D), 
        .V(V), 
        .Q(Q), 
        .R(R), 
        .done(done)
    );

    // Generador de reloj (Periodo = 10)
    always #5 clk = ~clk;

    // Pruebas
    
    initial begin
        $dumpfile("simulacion_div.vcd");
        $dumpvars(0, div_tb);

        // Condiciones iniciales
        clk = 0;
        rst = 1;
        start = 0;
        D = 16'd0;
        V = 16'd0;

        // Quitar reset
        #20;
        rst = 0;
        
        // ---------------------------------------------------
        // Prueba 1: Dividir 45 entre 6 (Esperado: Q=7, R=3)
        // ---------------------------------------------------
        #10;
        D = 16'd45;
        V = 16'd6;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Esperar a que termine la división
        while (!done) begin
            @(posedge clk);
        end
        
        $display("Prueba 1 Terminada: 45 / 6 -> Cociente = %d, Residuo = %d", Q, R);

        // ---------------------------------------------------
        // Prueba 2: Dividir 100 entre 15 (Esperado: Q=6, R=10)
        // ---------------------------------------------------
        #20;
        D = 16'd100;
        V = 16'd15;
        
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        while (!done) begin
            @(posedge clk);
        end
        
        $display("Prueba 2 Terminada: 100 / 15 -> Cociente = %d, Residuo = %d", Q, R);

        // Finalizar simulación
        #20;
        $finish;
    end

endmodule
