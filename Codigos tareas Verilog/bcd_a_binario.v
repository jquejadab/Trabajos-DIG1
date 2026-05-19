//============================================================
//  Conversor BCD -> Binario (Reverse Double Dabble)
//============================================================
module bcd_a_binario #(
    parameter N = 8,
    parameter D = 3
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [4*D-1:0] BCD,
    output reg [N-1:0] B,
    output reg done
);

    localparam S_IDLE = 2'd0;
    localparam S_CHECK = 2'd1;
    localparam S_PROC = 2'd2;
    localparam S_FINISH = 2'd3;

    reg [1:0] state, next_state;
    reg [4*D+N-1:0] R;
    reg [($clog2(N+1)-1):0] cnt;

    wire cnt_zero = (cnt == 0);

    // Función de ajuste inverso: si el dígito es >= 8, se le restan 3
    function [3:0] sub3;
        input [3:0] d;
        begin
            sub3 = (d >= 4'd8) ? (d - 4'd3) : d;
        end
    endfunction

    // Primero realizamos el desplazamiento hacia la derecha
    wire [4*D+N-1:0] R_shifted = R >> 1;

    // Ajustamos combinacionalmente cada uno de los D dígitos BCD
    reg [4*D-1:0] bcd_adj;
    integer i;
    always @(*) begin
        for (i = 0; i < D; i = i + 1)
            bcd_adj[i*4 +: 4] = sub3(R_shifted[N + i*4 +: 4]);
    end

    // Unimos los dígitos BCD corregidos con la parte binaria desplazada
    wire [4*D+N-1:0] R_next = {bcd_adj, R_shifted[N-1:0]};

    // Máquina de Estados (FSM): Lógica del próximo estado
    always @(*) begin
        case (state)
            S_IDLE: next_state = start ? S_CHECK : S_IDLE;
            S_CHECK: next_state = cnt_zero ? S_FINISH : S_PROC;
            S_PROC: next_state = S_CHECK;
            S_FINISH: next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end

    // Máquina de Estados (FSM): Registro de estado
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else state <= next_state;
    end

    // Ruta de Datos (Datapath)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            R <= 0;
            cnt <= 0;
            B <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        // Cargamos el BCD en la parte alta y rellenamos la baja con ceros
                        R <= { BCD, {N{1'b0}} };
                        cnt <= N;
                    end
                end
                S_PROC: begin
                    R <= R_next;
                    cnt <= cnt - 1;
                end
                S_FINISH: begin
                    // La parte baja de R contiene ahora el valor binario puro
                    B <= R[N-1:0];
                    done <= 1;
                end
                default: ;
            endcase
        end
    end
endmodule

//============================================================
//  Testbench (Configurado para interactuar por consola)
//============================================================
module tb_bcd_a_binario;
    parameter N = 8;
    parameter D = 3;
    reg clk = 0, rst = 1, start = 0;
    reg [4*D-1:0] BCD = 0;
    wire [N-1:0] B;
    wire done;
    integer errors = 0;
    
    integer user_BCD;

    bcd_a_binario #(.N(N), .D(D)) uut (
        .clk(clk), .rst(rst), .start(start),
        .BCD(BCD), .B(B), .done(done)
    );

    always #5 clk = ~clk;

    // Función auxiliar para convertir un entero normal a formato vectorial BCD
    function [4*D-1:0] to_bcd(input integer val);
        integer temp, j;
        begin
            to_bcd = 0;
            temp = val;
            for (j = 0; j < D; j = j + 1) begin
                to_bcd[j*4 +: 4] = temp % 10;
                temp = temp / 10;
            end
        end
    endfunction

    task print_bcd(input [4*D-1:0] v);
        integer j;
        begin
            for (j = D-1; j >= 0; j = j - 1) $write("%0d", v[j*4 +: 4]);
        end
    endtask

    task run_test(input integer decimal_val);
        reg [4*D-1:0] bcd_input;
        begin
            bcd_input = to_bcd(decimal_val);
            @(posedge clk);
            BCD = bcd_input; start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
            $write("  BCD de entrada = ");
            print_bcd(BCD);
            $display("  ->  Binario obtenido = %3d (bin: %b)   %s", 
                     B, B, (B == decimal_val) ? "OK" : "FAIL");
            if (B != decimal_val) errors = errors + 1;
        end
    endtask

    initial begin
        $dumpfile("bcd_a_binario.vcd");
        $dumpvars(0, tb_bcd_a_binario);
        #2  rst = 1;
        #20 rst = 0;
        $display("=== Conversor BCD -> Binario (N=%0d, D=%0d) ===", N, D);
        
        if ($value$plusargs("BCD=%d", user_BCD)) begin
            $display("Ejecutando con el valor BCD ingresado...");
            run_test(user_BCD);
        end else begin
            $display("ADVERTENCIA: No se detecto +BCD por consola.");
            $display("Ejecutando set de pruebas automaticas por defecto:");
            run_test(0);
            run_test(9);
            run_test(45);
            run_test(100);
            run_test(128);
            run_test(255);
        end
        
        $display("=== Fin (errores: %0d) ===", errors);
        $finish;
    end
endmodule