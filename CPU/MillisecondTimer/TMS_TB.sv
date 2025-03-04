module TimerMS_TB;

	logic waiting;
	logic [15:0] repeats;
	logic start, clk, reset;

	TimerMS #(.CLK_SPEED(27000000)) t0 (.*);
	
	initial
	begin
		start = '0;
		clk = '0;
		reset = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #18519ps clk = ~ clk;
	end
	
	initial
	begin
		repeats = 16'd2;
		start = '1;
		#100ns;
		start = '0;
	end
endmodule