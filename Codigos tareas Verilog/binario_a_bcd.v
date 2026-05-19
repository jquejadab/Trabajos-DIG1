//============================================================
//  Conversor Binario -> BCD (Double Dabble)
//============================================================
module binario_a_bcd #(
    parameter N = 8,
    parameter D = 3
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [N-1:0] B,
    output reg [4*D-1:0] BCD,
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

    function [3:0] adj5;
        input [3:0] d;
        begin
            adj5 = (d >= 4'd5) ? (d + 4'd3) : d;
        end
    endfunction

    reg [4*D-1:0] bcd_adj;
    integer i;
    always @(*) begin
        for (i = 0; i < D; i = i + 1)
            bcd_adj[i*4 +: 4] = adj5(R[N + i*4 +: 4]);
    end

    wire [4*D+N-1:0] R_next = {bcd_adj, R[N-1:0]} << 1;

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
            R <= 0;
            cnt <= 0;
            BCD <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) begin
                        R <= { {(4*D){1'b0}}, B };
                        cnt <= N;
                    end
                end
                S_PROC: begin
                    R <= R_next;
                    cnt <= cnt - 1;
                end
                S_FINISH: begin
                    BCD <= R[4*D+N-1 : N];
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
module tb_binario_a_bcd;
    parameter N = 8;
    parameter D = 3;
    reg clk = 0, rst = 1, start = 0;
    reg [N-1:0] B = 0;
    wire [4*D-1:0] BCD;
    wire done;
    integer errors = 0;
    
    // Variable requerida para recibir el dato de consola
    integer user_B;

    binario_a_bcd #(.N(N), .D(D)) uut (
        .clk(clk), .rst(rst), .start(start),
        .B(B), .BCD(BCD), .done(done)
    );

    always #5 clk = ~clk;

    function [4*D-1:0] bin_to_bcd_ref(input [N-1:0] b);
        reg [N-1:0] temp;
        integer i;
        begin
            bin_to_bcd_ref = 0;
            temp = b;
            for (i = 0; i < D; i = i + 1) begin
                bin_to_bcd_ref[i*4 +: 4] = temp % 10;
                temp = temp / 10;
            end
        end
    endfunction

    task print_bcd(input [4*D-1:0] v);
        integer i;
        begin
            for (i = D-1; i >= 0; i = i - 1) $write("%0d", v[i*4 +: 4]);
        end
    endtask

    task run_test(input [N-1:0] b);
        reg [4*D-1:0] expected;
        begin
            expected = bin_to_bcd_ref(b);
            @(posedge clk);
            B = b; start = 1;
            @(posedge clk);
            start = 0;
            wait (done == 1);
            @(posedge clk);
            $write("  bin = %3d  ->  BCD = ", b);
            print_bcd(BCD);
            $write("   (esperado ");
            print_bcd(expected);
            $write(")   %s\n", (BCD == expected) ? "OK" : "FAIL");
            if (BCD != expected) errors = errors + 1;
        end
    endtask

    initial begin
        $dumpfile("binario_a_bcd.vcd");
        $dumpvars(0, tb_binario_a_bcd);
        #2  rst = 1;
        #20 rst = 0;
        $display("=== Conversor Binario -> BCD (N=%0d, D=%0d) ===", N, D);
        
        // Comprobar si el usuario ingreso correctamente el comando +B
        if ($value$plusargs("B=%d", user_B)) begin
            $display("Ejecutando con valor del usuario...");
            run_test(user_B);
        end else begin
            $display("ADVERTENCIA: No se detecto +B.");
            $display("Uso en consola: vvp bcdfunc.vvp +B=<valor>");
            $display("Ejecutando prueba automatica por defecto (123):");
            run_test(8'd123);
        end
        
        $display("=== Fin (errores: %0d) ===", errors);
        $finish;
    end
endmodule