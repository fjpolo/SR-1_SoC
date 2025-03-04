module FTU_TB;
	logic send_frame;
	logic clk, reset;
	
	FrameTimingUnit ftu0 (.*);
	
	initial
	begin
		clk = '0;
		reset = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #1ns clk = ~clk;
	end
endmodule
	