`define PROG_LENGTH 16 //MUST BE EVEN!!

module MAU4_TB;
	logic all_busy, any_busy;
	logic [15:0] dbs, dbi;
	tri [15:0] data_bus_supr, data_bus_infr;
	logic start, use_x2_mode, clk, reset, read_output, set_matrix_address, write_matrix, write_db;
	
	assign data_bus_supr = write_db ? dbs : 'z;
	assign data_bus_infr = write_db ? dbi : 'z;
	
	logic [15:0] prog_to_load [`PROG_LENGTH] = '{
		'{16'b0011110000000000}, 	//00 A	---------
		'{16'b0000000000000000},	//01 B	|A B C D|
		'{16'b0000000000000000},	//02 C	|E F G H|
		'{16'b0000000000000000},	//03 D	|I J K L|
		'{16'b0000000000000000}, 	//04 E	|M N O P|
		'{16'b0011101011101110}, 	//05 F	---------
		'{16'b1011100000000000},	//06 G
		'{16'b0000000000000000}, 	//07 H
		'{16'b0000000000000000}, 	//08 I
		'{16'b0011100000000000},	//09 J
		'{16'b0011101011101110}, 	//10 K
		'{16'b0000000000000000},	//11 L
		'{16'b0000000000000000}, 	//12 M
		'{16'b0000000000000000}, 	//13 N
		'{16'b0000000000000000}, 	//14 O
		'{16'b0011110000000000} 	//15 P
	};
	
	MAU4 m4_0 (.*);
	
	initial
	begin
		dbs = '0;
		dbi = '0;
	
		start = '0;
		use_x2_mode = '0;
		clk = '0;
		read_output = '0;
		set_matrix_address = '0;
		write_matrix = '0;
		write_db = '0;
		
		reset = 0;
		#1ns;
		reset = 1;
		#1ns;
		reset = 0;
		#1ns;
		forever #10ns clk = ~clk;
	end
	
	initial
	begin
		//programming
		#10ns write_db = '1;
		
		for(int i = 0; i < (`PROG_LENGTH / 2); i++)
		begin
			#20ns;
			dbs = i;
			set_matrix_address = '1;
			#20ns;
			set_matrix_address = '0;
			write_matrix = '1;
			dbs = prog_to_load[i*2];
			dbi = prog_to_load[i*2 + 1];
			#20ns;
			write_matrix = '0;
		end
		
		//Reset address ready for multiplication
		#20ns;
		dbs = '0;
		set_matrix_address = '1;
		#20ns;
		set_matrix_address = '0;
		
		#20ns;
		start = '1;
		dbs = 16'b0100101110000000;
		dbi = 16'b0100100100000000;
		#25ns;
		start = '0;
		write_db = '0;
		#20ns;
		write_db = '1;
		dbs = 16'b0100010000000000;
		dbi = 16'b0011110000000000;
		#20ns;
		write_db = '0;
		
		#500ns;
		read_output = '1;
		#38ns;
		read_output = '0;
		
		#99ns;
		write_db = '1;
		dbs = '0;
		dbi = '0;
		set_matrix_address = '1;
		use_x2_mode = '1;
		#20ns;
		set_matrix_address = '0;
		use_x2_mode = '0;
		write_db = '0;
		#15ns;
		write_db = '1;
		start = '1;
		use_x2_mode = '1;
		dbs = 16'b0100101110000000;
		dbi = 16'b0100100100000000;
		#40ns;
		dbs = 16'b0100010000000000;
		dbi = 16'b0011110000000000;
		#20ns;  
		start = '0;
		write_db = '0;
		use_x2_mode = '0;
		
		#495ns;
		use_x2_mode = '1;
		read_output = '1;
		#30ns;
		use_x2_mode = '0;
		read_output = '0;
		
		//Testing return to x4
		//Reset address ready for multiplication
		#20ns;
		write_db = '1;
		dbs = '0;
		set_matrix_address = '1;
		#20ns;
		set_matrix_address = '0;
		
		#20ns;
		start = '1;
		dbs = 16'b0100101110000000;
		dbi = 16'b0100100100000000;
		#25ns;
		start = '0;
		write_db = '0;
		#20ns;
		write_db = '1;
		dbs = 16'b0100010000000000;
		dbi = 16'b0011110000000000;
		#20ns;
		write_db = '0;
		
		#500ns;
		read_output = '1;
		#38ns;
		read_output = '0;
		
		#100ns;
		$stop;
	end
endmodule