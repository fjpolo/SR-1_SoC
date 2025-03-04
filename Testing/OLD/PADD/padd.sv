// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module padd_TB;

	logic [17:0] dout, so, sbo, b, si;
	logic ce, clk, reset;
	
	Gowin_PADD padd0 (
        .dout(dout), //output [17:0] dout
        .so(so), //output [17:0] so
        .sbo(sbo), //output [17:0] sbo
        .b(b), //input [17:0] b
        .si(si), //input [17:0] si
        .ce(ce), //input ce
        .clk(clk), //input clk
        .reset(reset) //input reset
    );
	
	initial
	begin
		b = '0;
		si = '0;
		ce = '0;
		reset = '0;
		clk = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #37ns clk = ~clk;
	end
	
	initial
	begin
		#20ns ce = '1;
		#50ns b = 18'd20;
		#50ns si = 18'd3;
	end
	
endmodule
