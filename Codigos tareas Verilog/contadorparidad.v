//============================================================
//  Contador de Unos + Determinador de Paridad
//============================================================
module contador_unos_paridad #(
    parameter N = 8
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [N-1:0] X,
    output reg [($clog2(N+1)-1):0] Counter,
    output wire Paridad,
    output reg done
);

    localparam S_IDLE = 2'd0;
    localparam S_CHECK = 2'd1;
    localparam S_PROC = 2'd2;
    localparam S_FINISH = 2'd3;

    reg [1:0] state, next_state;
    reg [N-1:0] X_reg;
    reg [($clog2(N+1)-1):0] cnt;

    wire x0 = X_reg[0];
    wire cnt_zero = (cnt == 0);

    assign Paridad = Counter[0];

    always @(*) begin
        case (state)
            S_IDLE: next_state = start ? S_CHECK : S_IDLE;
            S_CHECK: next_state = cnt_zero ? S_FINISH : S_PROC;
            S_PROC: next_state = S_CHECK;
            S_FINISH: next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else state <= next_state;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X_reg <= 0;
            cnt <= 0;
            Counter <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        X_reg <= X;
                        Counter <= 0;
                        cnt <= N;
                    end
                end
                S_PROC: begin
                    if (x0) Counter <= Counter + 1;
                    X_reg <= X_reg >> 1;
                    cnt <= cnt - 1;
                end
                S_FINISH: begin
                    done <= 1;
                end
                default: ;
            endcase
        end
    end
endmodule

//============================================================
//  Testbench
//============================================================
module tb_contador_unos_paridad;
    parameter N = 8;
    localparam M = $clog2(N+1);
    reg clk = 0, rst = 1, start = 0;
    reg [N-1:0] X = 0;
    wire [M-1:0] Counter;
    wire Paridad;
    wire done;
    integer errors = 0;
    integer user_X;

    contador_unos_paridad #(.N(N)) uut (
        .clk(clk), .rst(rst), .start(start),
        .X(X), .Counter(Counter), .Paridad(Paridad), .done(done)
    );

    always #5 clk = ~clk;

    function [M-1:0] popcount(input [N-1:0] v);
        integer i;
        begin
            popcount = 0;
            for (i = 0; i < N; i = i + 1)
                if (v[i]) popcount = popcount + 1;
        end
    endfunction

    task run_test(input [N-1:0] x);
        reg [M-1:0] exp_c;
        reg exp_p;
        begin
            exp_c = popcount(x);
            exp_p = exp_c[0];
            @(posedge clk);
            X = x; start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
            $display("  X=%0d (binario: %b) -> unos=%0d | paridad=%0d (%s)",
                     x, x, Counter, Paridad, (Paridad == 0) ? "PAR" : "IMPAR");
            if ((Counter != exp_c) || (Paridad != exp_p)) errors = errors + 1;
        end
    endtask

    initial begin
        $dumpfile("contador_unos.vcd");
        $dumpvars(0, tb_contador_unos_paridad);
        #2  rst = 1;
        #20 rst = 0;
        $display("=== Contador de Unos y Paridad (N=%0d) ===", N);
        
        if ($value$plusargs("X=%d", user_X)) begin
            $display("Ejecutando con valor del usuario...");
            run_test(user_X);
        end else begin
            $display("ADVERTENCIA: No se dectecto +X. Usando valor por defecto (170):");
            run_test(8'b10101010);
        end
        
        $display("=== Fin (errores: %0d) ===", errors);
        $finish;
    end
endmodule