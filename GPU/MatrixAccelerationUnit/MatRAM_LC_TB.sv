module MatRAM_Lane_ControllerTB;

	logic [9:0] address_out;
	logic [9:0] address_in;
	logic clk, reset, mau_start, set_address;
	
	MatRAM_Lane_Controller mr_lc0 (.*);
	
	initial
	begin
		address_in = 10'd44;
		clk = '0;
		mau_start = '0;
	
		reset = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		forever #5ns clk = ~clk;
	end
	
	initial
	begin
		#25ns mau_start = '1;
		#10ns mau_start	= '0;
	end
endmodule