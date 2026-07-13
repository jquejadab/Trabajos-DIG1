module raices_tb;

reg clk;
reg rst;
reg start;
reg [15:0]N;

wire [7:0]Q;
wire [9:0]R;
wire done;

raices dut (.clk(clk),.rst(rst),.start(start),.N(N),.Q(Q),.R(R),.done(done));

always #5 clk = ~clk;

initial begin
    $dumpfile("simulacion_raices.vcd");
    $dumpvars(0, raices_tb);

    clk = 0;
    rst = 1;
    start = 0;
    N = 16'd0;

    #10 rst = 0;

    #10 N = 16'd144; 
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 1: N = %d | Raiz (Q) = %d | Residuo (R) = %d", N, Q, R);

    #20 N = 16'd625; 
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 2: N = %d | Raiz (Q) = %d | Residuo (R) = %d", N, Q, R);

    #20 N = 16'd10000; 
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 3: N = %d | Raiz (Q) = %d | Residuo (R) = %d", N, Q, R);

    #20 $finish;
end

endmodule
