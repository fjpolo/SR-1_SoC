module MemoryControllerTB;
	logic [15:0] address; 
	logic [7:0] current_ram, mm_prescale;
	tri [15:0] data_bus;
	logic set_mar, read_m, write_m, read_r, write_r, clk;
	logic set_mar_btn, set_ram_btn, programming_mode, reset, prog_clk;
	
	MemoryController mc(.*);
	
	logic [7:0] db;
	
	initial
	begin
		clk = '0;
		forever begin #10ns; clk = !clk; end;
	end
	
	assign data_bus = set_mar || write_m || programming_mode ? db : 'z;
	
	initial
	begin
		set_mar = '0;
		read_m = '0;
		write_m = '0;
		read_r = '0;
		write_r = '0;
		set_mar_btn = '0;
		set_ram_btn = '0;
		programming_mode = '0;
		reset = '0;
		prog_clk = '0;
		
		for (int i = 0; i < 10; i++)
		begin
			#20ns;
			write_r = '0;
			set_mar = '1;
			db = i;
			
			#20ns;
			set_mar = '0;
			db = 0;
			
			#20ns;
			write_m = '1;
			db = 255 - i;
			
			#20ns;
			write_m = '0;
			write_r = '1;
			db = 0;	
		end
		
		#20ns;
		write_r = '0;
		read_m = '1;
		
		#20ns;
		
		#20ns;
		read_m = '0;
		
		#20ns;
		set_mar = '1;
		db = 8;
		
		#20ns;
		set_mar = '0;
		read_r = '1;
		
		#20ns;
		read_r = '0;
		set_mar = '1;
		db = 16;
		
		#20ns;
		set_mar = '0;
		write_r = '1;
		
		#20ns;
		write_r = '0;
		
		#20ns;
		programming_mode = '1;
		db = 25;
		set_mar_btn = '1;
		
		#20ns;
		db = 225;
		set_mar_btn = '0;
		set_ram_btn = '1;
		
		#20ns;
		$stop;
	end
	
endmodule
