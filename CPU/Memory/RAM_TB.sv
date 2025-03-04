module RAM_TB;
	logic [15:0] db_out, gpu_cpu_data, gpu_pca, gpu_pcb;
	logic [7:0] clk_pre, gpu_repeat, gpu_pcai, gpu_pcbi, gpu_instr;
	logic [15:0] data_bus, wide_sw, gpu_data_out, gpu_fp2i;
	logic [7:0] thin_sw, buttons;
	logic clk, reset, half_mode, read, write, set_address, set_transfer_addr, data_transfer;
	
	logic [15:0] db_data;
	
	assign data_bus = db_out | db_data;
	
	RAM ram0 (.*);
	
	initial
	begin
		db_data = '0;
		wide_sw = 16'd24242;
		gpu_data_out = 16'd54222;
		gpu_fp2i = 16'd64091;
		thin_sw = 8'b11001111;
		buttons = 8'b01001010;
		data_transfer = '0;
		set_transfer_addr = '0;
		set_address = '0;
		write = '0;
		read = '0;
		half_mode = '0;
	
		clk = '0;
		reset = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #5ns clk = ~clk;
	end
		
	initial
	begin
		#12ns;
		db_data = 16'd2149;
		write = '1;
		#10ns;
		db_data = '0;
		write = '0;
		#10ns;
		read = '1;
		#10ns;
		//READING 2B things
		read = '0;
		db_data = 16'd32755;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		#10ns;
		read = '0;
		db_data = 16'd32753;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		#10ns;
		read = '0;
		db_data = 16'd32750;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		#10ns;
		//READING 1B things
		read = '0;
		db_data = 16'd32752;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		half_mode = '1;
		#10ns;
		read = '0;
		db_data = 16'd32749;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		half_mode = '1;
		#10ns;
		read = '0;
		db_data = 16'd32741;
		set_address = '1;
		#20ns;
		db_data = '0;
		set_address = '0;
		read = '1;
		half_mode = '1;
		#10ns;
		read = '0;
		half_mode = '0;
		//WRITING TO GPU REGS
		db_data = 16'd32758;
		set_address = '1;
		#10ns;
		db_data = 16'd12345;
		set_address = '0;
		write = '1;
		#10ns;
		write = '0;
		db_data = 16'd32766;
		set_address = '1;
		#10ns;
		db_data = 16'd225;
		set_address = '0;
		write = '1;
		half_mode = '1;
		#10ns;
		write = '0;
		half_mode = '0;
		db_data = 16'd32762;
		set_transfer_addr = '1;
		#10ns;
		set_transfer_addr = '0;
		db_data = '0;
		set_address = '1;
		#10ns;
		set_address = '0;
		#10ns;
		data_transfer = '1;
		#10ns;
		data_transfer = '0;
		#10ns;
		data_transfer = '1;
		#10ns;
		data_transfer = '0;
		#10ns;
		$stop;
	end
endmodule