module binario_bcd_tb;

reg clk;
reg rst;
reg start;
reg [15:0]B;

wire [19:0]BCD;
wire done;

binario_bcd dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .B(B),
    .BCD(BCD),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("simulacion_binario_bcd.vcd");
    $dumpvars(0, binario_bcd_tb);

    clk = 0;
    rst = 1;
    start = 0;
    B = 16'd0;

    #10 rst = 0;

    #10 B = 16'd255;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 1: Binario = %d | BCD = %h", B, BCD);

    #20 B = 16'd4096;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 2: Binario = %d | BCD = %h", B, BCD);

    #20 B = 16'd9999;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 3: Binario = %d | BCD = %h", B, BCD);

    #20 B = 16'd65535;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 4: Binario = %d | BCD = %h", B, BCD);

    #20 $finish;
end

endmodule
