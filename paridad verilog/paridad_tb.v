module paridad_tb;

reg clk;
reg rst;
reg start;
reg [15:0]X;

wire [4:0]Counter;
wire Paridad;
wire done;

paridad dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .X(X),
    .Counter(Counter),
    .Paridad(Paridad),
    .done(done)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("simulacion_paridad.vcd");
    $dumpvars(0, paridad_tb);

    clk = 0;
    rst = 1;
    start = 0;
    X = 16'd0;

    #10 rst = 0;

    #10 X = 16'b0000_0000_0000_0111;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 1: X = %b | Unos contados = %d | Paridad = %b", X, Counter, Paridad);

    #20 X = 16'b1010_1010_1010_1010;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 2: X = %b | Unos contados = %d | Paridad = %b", X, Counter, Paridad);

    #20 X = 16'b0000_0000_0000_0000;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 3: X = %b | Unos contados = %d | Paridad = %b", X, Counter, Paridad);

    #20 X = 16'b1111_1111_1111_1111;
    start = 1;
    #10 start = 0;
    
    @(posedge done);
    $display("Prueba 4: X = %b | Unos contados = %d | Paridad = %b", X, Counter, Paridad);

    #20 $finish;
end

endmodule
