//============================================================
//  Multiplicador Binario (sin signo) — suma y desplazamiento
//  A[N-1:0] * B[N-1:0] = P[2N-1:0]
//============================================================
module multiplicador #(
    parameter N = 4
)(
    input  wire             clk,
    input  wire             rst,       // reset asíncrono activo en alto
    input  wire             start,
    input  wire [N-1:0]     A,         // multiplicando
    input  wire [N-1:0]     B,         // multiplicador
    output reg  [2*N-1:0]   P,         // producto
    output reg              done
);
//---- Estados de la FSM ----
    localparam S_IDLE   = 2'd0;
    localparam S_CHECK  = 2'd1;
    localparam S_OPER   = 2'd2;
    localparam S_FINISH = 2'd3;

    reg [1:0]                state, next_state;
//---- Registros de la ruta de datos ----
    reg [N-1:0]              M;        // multiplicando (fijo durante la operación)
    reg [N-1:0]              Q;        // multiplicador (shift right)
    reg [N:0]                ACC;      // acumulador, N+1 bits para tolerar el acarreo
    reg [$clog2(N+1)-1:0]    cnt;      // contador de iteraciones

    //---- Señales de status ----
    wire q0       = Q[0];
    wire cnt_zero = (cnt == 0);

    //---- Lógica combinacional: suma y shift en un solo ciclo ----
    wire [N:0]   acc_plus       = ACC + {1'b0, M};
    wire [2*N:0] combined_after = q0 ? {acc_plus, Q} : {ACC, Q};
    wire [2*N:0] combined_shft  = combined_after >> 1;

    //---- FSM: próximo estado ----
    always @(*) begin
        case (state)
            S_IDLE:   next_state = start    ? S_CHECK  : S_IDLE;
            S_CHECK:  next_state = cnt_zero ? S_FINISH : S_OPER;
            S_OPER:   next_state = S_CHECK;
            S_FINISH: next_state = S_IDLE;
            default:  next_state = S_IDLE;
        endcase
    end

    //---- FSM: registro de estado ----
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else     state <= next_state;
    end

    //---- Ruta de datos ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            M    <= 0;
            Q    <= 0;
            ACC  <= 0;
            cnt  <= 0;
            P    <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        M   <= A;
                        Q   <= B;
                        ACC <= 0;
                        cnt <= N;
                    end
                end
                S_OPER: begin
                    {ACC, Q} <= combined_shft;
                    cnt      <= cnt - 1;
                end
                S_FINISH: begin
                    P    <= {ACC[N-1:0], Q};
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
module tb_multiplicador;
    parameter N = 16;  // Cambiado a 16 bits para soportar números grandes
    reg            clk = 0, rst = 1, start = 0;
    reg  [N-1:0]   A = 0, B = 0;
    wire [2*N-1:0] P;
    wire           done;
    integer        errors = 0;

    // Variables globales requeridas para recibir los datos de consola
    integer user_A;
    integer user_B;

    multiplicador #(.N(N)) uut (
        .clk(clk), .rst(rst), .start(start),
        .A(A), .B(B), .P(P), .done(done)
    );

    always #5 clk = ~clk;  // reloj de 10 ns (100 MHz)

    task run_test(input [N-1:0] a, input [N-1:0] b);
        reg [2*N-1:0] expected;
        begin
            expected = a * b;
            @(posedge clk);
            A = a; B = b; start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
            $display("  %0d * %0d = %0d   (esperado %0d)   %s",
                     a, b, P, expected, (P == expected) ? "OK" : "FAIL");
            if (P != expected) errors = errors + 1;
        end
    endtask

    initial begin
        $dumpfile("multiplicador.vcd");
        $dumpvars(0, tb_multiplicador);
        #2  rst = 1;
        #20 rst = 0;
        
        $display("=== Multiplicador (N=%0d) ===", N);
        
        // Comprobar si el usuario ingresó correctamente los comandos +A y +B
        if ($value$plusargs("A=%d", user_A) && $value$plusargs("B=%d", user_B)) begin
            $display("Ejecutando con valores del usuario: A=%0d, B=%0d", user_A, user_B);
            run_test(user_A, user_B);
        end else begin
            $display("ADVERTENCIA: No se ingresaron valores correctos.");
            $display("Uso en consola: vvp multiplicadorfunc.vvp +A=<valor> +B=<valor>");
            $display("Ejecutando prueba automatica por defecto (15 * 1):");
            run_test(15, 1);
        end
        
        $display("=== Fin (errores: %0d) ===", errors);
        $finish;
    end
endmodule