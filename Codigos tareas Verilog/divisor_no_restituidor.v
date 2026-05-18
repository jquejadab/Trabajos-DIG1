//============================================================
//  Divisor Binario No Restituidor (sin signo)
//============================================================
module divisor_no_restituidor #(
    parameter N = 8
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [N-1:0] D,
    input wire [N-1:0] V,
    output reg [N-1:0] Q,
    output reg [N-1:0] R_out,
    output reg done
);

    localparam S_IDLE = 3'd0;
    localparam S_CHECK = 3'd1;
    localparam S_PROC = 3'd2;
    localparam S_CORR = 3'd3;
    localparam S_FINISH = 3'd4;

    reg [2:0] state, next_state;
    reg [N:0] R;
    reg [N-1:0] V_reg;
    reg [N-1:0] Q_reg;
    reg [($clog2(N+1)-1):0] cnt;

    wire sign_R = R[N];
    wire cnt_zero = (cnt == 0);

    wire [N:0] R_shifted = {R[N-1:0], Q_reg[N-1]};
    wire shifted_sign = R_shifted[N];
    wire [N:0] R_op = shifted_sign ? (R_shifted + {1'b0, V_reg}) : (R_shifted - {1'b0, V_reg});
    wire new_q0 = ~R_op[N];

    always @(*) begin
        case (state)
            S_IDLE: next_state = start ? S_CHECK : S_IDLE;
            S_CHECK: next_state = cnt_zero ? (sign_R ? S_CORR : S_FINISH) : S_PROC;
            S_PROC: next_state = S_CHECK;
            S_CORR: next_state = S_FINISH;
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
            R <= 0;
            V_reg <= 0;
            Q_reg <= 0;
            cnt <= 0;
            Q <= 0;
            R_out <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        R <= 0;
                        V_reg <= V;
                        Q_reg <= D;
                        cnt <= N;
                    end
                end
                S_PROC: begin
                    R <= R_op;
                    Q_reg <= {Q_reg[N-2:0], new_q0};
                    cnt <= cnt - 1;
                end
                S_CORR: begin
                    R <= R + {1'b0, V_reg};
                end
                S_FINISH: begin
                    Q <= Q_reg;
                    R_out <= R[N-1:0];
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
module tb_divisor;
    parameter N = 8;
    reg clk = 0, rst = 1, start = 0;
    reg [N-1:0] D = 0, V = 0;
    wire [N-1:0] Q, R_out;
    wire done;
    integer errors = 0;
    
    // Variables requeridas para recibir los datos de consola
    integer user_D;
    integer user_V;

    divisor_no_restituidor #(.N(N)) uut (
        .clk(clk), .rst(rst), .start(start),
        .D(D), .V(V), .Q(Q), .R_out(R_out), .done(done)
    );

    always #5 clk = ~clk;

    task run_test(input [N-1:0] d, input [N-1:0] v);
        reg [N-1:0] exp_q, exp_r;
        begin
            if (v == 0) begin
                $display("  ERROR: Division por cero detectada. Evitando simulacion.");
            end else begin
                exp_q = d / v;
                exp_r = d % v;
                @(posedge clk);
                D = d; V = v; start = 1;
                @(posedge clk);
                start = 0;
                wait (done == 1);
                @(posedge clk);
                $display("  %0d / %0d = %0d  resto %0d   (esperado q=%0d r=%0d)   %s",
                         d, v, Q, R_out, exp_q, exp_r,
                         ((Q == exp_q) && (R_out == exp_r)) ? "OK" : "FAIL");
                if ((Q != exp_q) || (R_out != exp_r)) errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("divisor.vcd");
        $dumpvars(0, tb_divisor);
        #2  rst = 1;
        #20 rst = 0;
        $display("=== Divisor No Restituidor (N=%0d) ===", N);
        
        // Comprobar si el usuario ingreso correctamente los comandos +D y +V
        if ($value$plusargs("D=%d", user_D) && $value$plusargs("V=%d", user_V)) begin
            $display("Ejecutando con valores del usuario...");
            run_test(user_D, user_V);
        end else begin
            $display("ADVERTENCIA: No se detectaron +D y +V.");
            $display("Uso en consola: vvp divisorfunc.vvp +D=<valor> +V=<valor>");
            $display("Ejecutando prueba automatica por defecto (14 / 3):");
            run_test(14, 3); // 14 / 3 = 4 resto 2
        end
        
        $display("=== Fin (errores: %0d) ===", errors);
        $finish;
    end
endmodule