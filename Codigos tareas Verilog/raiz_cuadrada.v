//============================================================
//  Raíz Cuadrada Entera (algoritmo restituidor bit a bit)
//  X[2N-1:0]  ->  Y[N-1:0] (raíz),  R_out[N:0] (residuo)
//  Cumple:  Y² ≤ X < (Y+1)²   y   R_out = X − Y²
//============================================================
module raiz_cuadrada #(
    parameter N = 16
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,
    input  wire [2*N-1:0]   X,         // radicando
    output reg  [N-1:0]     Y,         // raíz
    output reg  [N:0]       R_out,     // residuo (hasta 2^(N+1)-1)
    output reg              done
);

    //---- Estados de la FSM ----
    localparam S_IDLE   = 2'd0;
    localparam S_CHECK  = 2'd1;
    localparam S_OPER   = 2'd2;
    localparam S_FINISH = 2'd3;

    reg [1:0]                state, next_state;

    //---- Registros de la ruta de datos ----
    reg [2*N-1:0]            X_reg;     // radicando registrado (shift left 2)
    reg [N:0]                R;         // residuo parcial, N+1 bits
    reg [N-1:0]              Y_reg;     // raíz parcial, N bits
    reg [$clog2(N+1)-1:0]    cnt;

    //---- Señales de status ----
    wire cnt_zero = (cnt == 0);

    //---- Lógica combinacional: shift de R + 2 bits nuevos, comparación, posible resta ----
    // R_shifted = {R, X_reg[2N-1:2N-2]}  (N+3 bits, conserva todo)
    wire [N+2:0] R_shifted  = {R, X_reg[2*N-1:2*N-2]};
    // trial = {Y, 2'b01} = 4*Y + 1   (extendido a N+3 bits)
    wire [N+2:0] trial_ext  = {1'b0, Y_reg, 2'b01};
    wire         can_sub    = (R_shifted >= trial_ext);
    wire [N+2:0] R_after_sub = R_shifted - trial_ext;

    //---- FSM ----
    always @(*) begin
        case (state)
            S_IDLE:   next_state = start    ? S_CHECK  : S_IDLE;
            S_CHECK:  next_state = cnt_zero ? S_FINISH : S_OPER;
            S_OPER:   next_state = S_CHECK;
            S_FINISH: next_state = S_IDLE;
            default:  next_state = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else     state <= next_state;
    end

    //---- Ruta de datos ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X_reg <= 0;
            R     <= 0;
            Y_reg <= 0;
            cnt   <= 0;
            Y     <= 0;
            R_out <= 0;
            done  <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        X_reg <= X;
                        R     <= 0;
                        Y_reg <= 0;
                        cnt   <= N;
                    end
                end
                S_OPER: begin
                    if (can_sub) begin
                        R     <= R_after_sub[N:0];
                        Y_reg <= {Y_reg[N-2:0], 1'b1};
                    end else begin
                        R     <= R_shifted[N:0];
                        Y_reg <= {Y_reg[N-2:0], 1'b0};
                    end
                    X_reg <= X_reg << 2;
                    cnt   <= cnt - 1;
                end
                S_FINISH: begin
                    Y     <= Y_reg;
                    R_out <= R;
                    done  <= 1;
                end
                default: ;
            endcase
        end
    end
endmodule

//============================================================
//  Testbench Interactivo
//============================================================
module tb_raiz_cuadrada;
    parameter N = 16; // 
    
    reg            clk = 0, rst = 1, start = 0;
    reg  [2*N-1:0] X = 0;
    wire [N-1:0]   Y;
    wire [N:0]     R_out;
    wire           done;
    integer        errors = 0;
    integer        status;
    reg [31:0]     temp_input;

    raiz_cuadrada #(.N(N)) uut (
        .clk(clk), .rst(rst), .start(start),
        .X(X), .Y(Y), .R_out(R_out), .done(done)
    );

    always #5 clk = ~clk;

    // Cálculo de referencia para validación automática
    function [N-1:0] int_sqrt(input [2*N-1:0] v);
        integer i;
        begin
            int_sqrt = 0;
            for (i = 0; i < (1<<N); i = i + 1)
                if (i*i <= v) int_sqrt = i[N-1:0];
        end
    endfunction

    task run_test(input [2*N-1:0] x);
        reg [N-1:0] exp_y;
        reg [N+1:0] exp_r;
        begin
            exp_y = int_sqrt(x);
            exp_r = x - exp_y*exp_y;
            @(posedge clk);
            X = x; start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
            $display("-> Resultado: sqrt(%0d) = %0d | Residuo = %0d (Esperado: y=%0d, r=%0d) [%s]",
                     x, Y, R_out, exp_y, exp_r,
                     ((Y == exp_y) && (R_out == exp_r)) ? "OK" : "FAIL");
            if ((Y != exp_y) || (R_out != exp_r)) errors = errors + 1;
        end
    endtask

    initial begin
        $dumpfile("raiz_cuadrada.vcd");
        $dumpvars(0, tb_raiz_cuadrada);
        
        // Secuencia de reset
        #2  rst = 1;
        #20 rst = 0;
        
        $display("=============================================================");
        $display("   SIMULACION INTERACTIVA DE RAIZ CUADRADA ENTERA (N = %0d)", N);
        $display("   Rango maximo de X admitido: 0 a %0d", (1<<(2*N))-1);
        $display("=============================================================");
        
        forever begin
            $display("\nIngrese un valor entero para X (o una letra para salir):");
            // 32'h8000_0000 es el descriptor estándar para 'stdin' en Verilog
            status = $fscanf(32'h8000_0000, "%d", temp_input);
            
            if (status == 1) begin
                X = temp_input[2*N-1:0];
                run_test(X);
            end else begin
                $display("\n=== Finalizando simulacion (Errores detectados: %0d) ===", errors);
                $finish;
            end
        end
    end
endmodule