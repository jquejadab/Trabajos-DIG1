`timescale 1ns / 1ps

module tb_bcd_binario;

    reg clk;
    reg rst;
    reg start;
    reg [19:0] bcd_in;
    
    wire [15:0] b_out;
    wire done;

    bcd_binario uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .bcd_in(bcd_in),
        .b_out(b_out),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("simulacion_bcd_binario.vcd");
        $dumpvars(0, tb_bcd_binario);
        clk = 0;
        rst = 1;
        start = 0;
        bcd_in = 20'd0;
        #22 rst = 0; 
        #10;

        // TEST 1: 12345
        @(negedge clk);
        bcd_in = 20'b0001_0010_0011_0100_0101; 
        start = 1;
        repeat(3) @(negedge clk); 
        start = 0;
        wait(done);
        $display("Test 1, BCD IN: %05h, Salida Binaria: %b | Valor Decimal: %d", bcd_in, b_out, b_out);
        #20;

        // TEST 2: 09876
        @(negedge clk);
        bcd_in = 20'b0000_1001_1000_0111_0110; 
        start = 1;   
        repeat(3) @(negedge clk); 
        start = 0;
        wait(done);
        $display("Test 2, BCD IN: %05h, Salida Binaria: %b | Valor Decimal: %d", bcd_in, b_out, b_out);
        #20;

        // TEST 3: 65535 (Máximo valor de 16 bits)
        @(negedge clk);
        bcd_in = 20'b0110_0101_0101_0011_0101; 
        start = 1;
        repeat(3) @(negedge clk); 
        start = 0;
        wait(done);
        $display("Test 3, BCD IN: %05h, Salida Binaria: %b | Valor Decimal: %d", bcd_in, b_out, b_out);

        $finish;
    end

endmodule
