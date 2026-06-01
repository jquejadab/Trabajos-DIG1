module control_multi (
    input clk,
    input rst,
    input init,
    input lsb_B,
    input z,
    output reg load,
    output reg init_c,
    output reg dec_c,
    output reg add,
    output reg sh,
    output reg done,
    output reg reset
);

    // Definición de estados
    localparam IDLE  = 2'd0;
    localparam ADD   = 2'd1;
    localparam SHIFT = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0] state, next_state;

    // Memoria de estado
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Lógica combinacional de siguiente estado y salidas
    always @(*) begin
        // Valores por defecto para evitar latches
        load   = 0;
        init_c = 0;
        add    = 0;
        sh     = 0;
        dec_c  = 0;
        done   = 0;
        reset  = 0;
        next_state = state;

        case (state)
            IDLE: begin
                if (init) begin
                    load = 1;
                    init_c = 1;
                    next_state = ADD;
                end
            end
            
            ADD: begin
                if (lsb_B) 
                    add = 1; // Solo suma si el bit menos significativo es 1
                next_state = SHIFT;
            end
            
            SHIFT: begin
                sh = 1;
                dec_c = 1; // Reduce el contador
                if (z) 
                    next_state = DONE; // Al procesar 16 bits, terminamos
                else 
                    next_state = ADD;  
            end
            
            DONE: begin
                done = 1;
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule