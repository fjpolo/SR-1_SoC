module FrameBuffer (output logic [7:0] frame_data,
					output logic busy,
					input logic [15:0] data_bus_supr, data_bus_infr,
					input logic [9:0] frame_address,
					input logic [7:0] word_in,
					input logic [6:0] x_coord_pix, x_coord_wrd,
					input logic [5:0] y_coord_pix,
					input logic [2:0] y_coord_wrd,
					input logic clk, send_next_data, reset, set_pixel, set_colour, set_word, set_pixel_line, page01);
	
	logic [9:0] internal_address, address_ff;
	logic [7:0] internal_data_in, internal_data_out, bit_vector;
	logic [2:0] y_coord_ff;
	logic [1:0] clear_old;
	logic rw, ce, colour;
	
	assign bit_vector = 8'd1 << y_coord_ff;
	
	enum {main, write_pixel} state;
	
	//Expects a 2048B Dual Port BSRAM unit
	DP_BSRAM bsram_fb (
        .douta(frame_data), //output [7:0] douta
        .doutb(internal_data_out), //output [7:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea((|clear_old) || send_next_data), //input cea
        .reseta(reset), //input reseta
        .wrea(clear_old == 2'd3), //input wrea
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb(ce | '1), //input ceb
        .resetb(reset), //input resetb
        .wreb(rw), //input wreb (0 is read, 1 is write)
        .ada({page01, frame_address}), //input [10:0] address a
        .dina('0), //input [7:0] dina
        .adb({~page01, internal_address}), //input [10:0] address b
        .dinb(internal_data_in) //input [7:0] dinb
    );
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			colour <= '1;
			address_ff <= '0;
			y_coord_ff <= '0;
			state <= main;
			clear_old <= '0;
		end
		else
		begin
			//Frame overwrite when sent
			if (send_next_data) 
				clear_old <= 2'd1;
			else if (|clear_old)
				clear_old <= clear_old + 2'd1;
		
			case (state)
			main : begin
				if (set_colour) colour <= data_bus_supr[0];
				else if (set_pixel_line | set_pixel)
				begin
					state <= write_pixel;
					address_ff <= internal_address;
					y_coord_ff <= set_pixel ? data_bus_infr[2:0] : y_coord_pix[2:0];
				end
			end
				
			write_pixel : begin
				state <= main;
			end
			endcase
		end
	end
	
	always_comb
	begin
		internal_address = '0;
		internal_data_in = '0;
		rw = '0;
		ce = '0;
		busy = '0;
		
		case (state)
		main : begin
			if (set_pixel)
			begin
				ce = '1;
				busy = '1;
				internal_address = (10'(data_bus_supr[6:0]) << 3) + (data_bus_infr[5:0] >> 3);
			end
			else if (set_pixel_line)
			begin
				ce = '1;
				busy = '1;
				internal_address = (10'(x_coord_pix) << 3) + (y_coord_pix >> 3);
			end
			else if (set_word)
			begin
				rw = '1;
				ce = '1;
				busy = '1;
				internal_address = (10'(x_coord_wrd) << 3) + (y_coord_wrd >> 3);
				internal_data_in = word_in;
			end
		end
		
		write_pixel : begin
			rw = '1;
			ce = '1;
			busy = '1;
			internal_address = address_ff;
			internal_data_in = colour ? (internal_data_out | bit_vector) : (internal_data_out & ~(bit_vector));
		end
		endcase
	end
endmodule