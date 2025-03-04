// Modelsim-ASE requires a timescale directive
`timescale 1 ns / 1 ns

module FrameBuffer_TB;
	logic [7:0] frame_data;
	logic busy;
	logic [15:0] data_bus_supr, data_bus_infr;
	logic [9:0] frame_address;
	logic [7:0] word_in;
	logic [6:0] x_coord_pix, x_coord_wrd;
	logic [5:0] y_coord_pix;
	logic [2:0] y_coord_wrd;
	logic clk, send_next_data, reset, set_pixel, set_colour, set_word, set_pixel_line, page01;
	
	FrameBuffer fb0 (.*);
	
	initial
	begin
		x_coord_pix = '0;
		x_coord_wrd = '0;
		y_coord_pix = '0;
		y_coord_wrd = '0;
		word_in = 8'd235;
		frame_address = '0;
		data_bus_infr = 16'd63;
		data_bus_supr = 16'd127;
		clk = '0;
		send_next_data = '0;
		reset = '0;
		set_pixel = '0;
		set_colour = '0;
		set_word = '0;
		set_pixel_line = '0;
		page01 = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #5ns clk= ~clk;
	end
	
	initial
	begin
		#6ns set_pixel = '1;
	end
endmodule