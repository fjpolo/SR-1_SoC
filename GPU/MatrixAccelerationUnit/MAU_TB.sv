// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module MAU_TB;
	
	logic busy;
	tri [15:0] data_bus_supr, data_bus_infr;
	logic [15:0] matRAM, dbs, dbi;
	logic start, mode, clk, reset, read_output, write_to_db;
	
	assign data_bus_supr = write_to_db ? dbs : 'z;
	assign data_bus_infr = write_to_db ? dbi : 'z;
	
	MAU #(.PRIMARY_OUTPUT("dbi")) mau0 (.*);
	
	initial 
	begin
		dbs = '0;
		dbi = '0;
		matRAM = '0;
		start = '0;
		mode = '0;
		clk = '0;
		read_output = '0;
		write_to_db = '1;
		
		reset = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #10ns clk = ~clk;
	end
	
	initial
	begin
		#20ns start = '1;
		#20ns start = '0;
		write_to_db = '1;
		dbs = 16'b0100101110000000;
		dbi = 16'b0100101110000000;
		matRAM = 16'b0011101011101110;
		#20ns;
		matRAM = 16'b1011100000000000;
		#20ns;
		matRAM = 16'b0011100000000000;
		#20ns;
		matRAM = 16'b0011101011101110;
		#300ns;
		write_to_db = '0;
		read_output = '1;
		#50ns;
		$stop;
	end
endmodule