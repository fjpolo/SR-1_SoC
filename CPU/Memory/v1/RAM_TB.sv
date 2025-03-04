// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module RAM_TB;

	logic [7:0] mm_prescale, mem_do;
	logic [7:0] mem_di, sw1, sw2, btn1;
	logic [14:0] address;
	logic read, write, mem_clk, mem_reset;
	
	RAM ram0 (.*);
	
	initial
	begin
		mem_di = '0;
		sw1 = 8'd26;
		sw2 = 8'd134;
		btn1 = 8'd247;
		address = '0;
		read = '0;
		write = '0;
		mem_clk = '0;
		mem_reset = '0;
		#1ns mem_reset = '1;
		#1ns mem_reset = '0;
		forever #5ns mem_clk = ~mem_clk;
	end
	
endmodule