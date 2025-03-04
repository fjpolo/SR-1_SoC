module VRAM_TB;
	tri [15:0] data_bus_supr, data_bus_infr;
	logic [15:0] dbs, dbi;
	logic read_a, read_b, write_a, write_b, clk, reset, set_address_a, set_address_b, set_address_b_incr, wdb;
	
	VRAM vram0 (.*);
	
	assign data_bus_supr = wdb ? dbs : 'z;
	assign data_bus_infr = wdb ? dbi : 'z;
	
	initial
	begin
		read_a = '0;
		read_b = '0;
		write_a = '0;
		write_b = '0;
		clk = '0;
		reset = '0;
		set_address_a = '0;
		set_address_b = '0;
		set_address_b_incr = '0;
		wdb = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #10ns clk = ~clk;
	end
	
	initial 
	begin
		#42ns;
		wdb = '1;
		dbi = 16'd2332;
		dbs = 16'd6143;
		set_address_a = '1;
		set_address_b = '1;
		#20ns;
		set_address_a = '0;
		set_address_b = '0;
		dbi = 16'd24332;
		dbs = 16'd8567;
		write_a = '1;
		write_b = '1;
		#20ns;
		write_a = '0;
		write_b = '0;
		wdb = '0;
		#20ns;
		read_a = '1;
		read_b = '1;
		#20ns;
		read_a = '0;
		read_b = '0;
		wdb = '1;
		dbi = 16'd10;
		dbs = 16'd5;
		set_address_a = '1;
		set_address_b_incr = '1;
		#20ns;
		set_address_a = '0;
		set_address_b_incr = '0;
		wdb = '0;
		#20ns;
	end
endmodule