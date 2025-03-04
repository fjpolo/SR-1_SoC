module DTCU_TB;
	
	logic [9:0] data_address;
	logic SCL, busy, SDA_OUT, NACK, get_next_data; 
	logic init_display, send_frame, clk, reset, SDA_IN;
	logic [7:0] frame_data;
	
	assign frame_data = 8'b01101001;
	
	DTCU dtcu0 (.*);
	
	initial
	begin
		init_display = '0;
		send_frame = '0;
		clk = '0;
		SDA_IN = '0;
		reset = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		forever #5ns clk = ~clk;
	end
	
	initial
	begin
		#4ns init_display = '1;
		#10ns init_display = 0;
		
		#110us send_frame = '1;
		#10ns send_frame = 0;
		
		#3160us send_frame = '1;
		#10ns send_frame = 0;
	end
endmodule