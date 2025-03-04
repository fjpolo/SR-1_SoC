module LDU_TB;

	logic [6:0] xOut, yOut;
	logic is_drawing;
	logic [6:0] x0, x1, y0, y1;
	logic start, clk, reset;
	
	LDU l0 (.*);
	
	initial
	begin
		x0 = 7'd63;
		y0 = 7'd31;
		
		x1 = 7'd0;
		y1 = 7'd0;
		
		start = '0;
		reset = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		clk = '0;
		
		forever #2ns clk = ~clk;
	end
	
	initial
	begin
		#10ns start = '1;
		#10ns start = '0;
	end
endmodule
