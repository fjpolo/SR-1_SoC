//Display Transmission Control Unit
`define COMMAND_LENGTH 11'd32 //INIT COMMAND LIST - 1

module DTCU #(parameter ADDRESS = 8'h78) (output logic [9:0] data_address,
										output logic SCL, busy, SDA_OUT, NACK, get_next_data, page01, 
										input logic [7:0] frame_data,
										input logic init_display, send_frame, clk, reset, SDA_IN);
	
	logic [10:0] index;
	logic [7:0] data_in;
	logic i2c_busy, i2c_NACK, i2c_data_saved, i2c_start, i2c_sending_data, i2c_send_addit_data, next_data_clk_lengthen, next_data_clk_precharge;
	
	//Commands and order from below
	//https://gist.github.com/VynDragon/f4b0e4d3b91572fc002dd02d91fed5cb 
	logic [7:0] init_commands [33] =  { 8'hAE,  // SET_DISP: display off
										8'h20,  // SET_MEM_ADDR: address setting
										8'h01,  // Vertical addressing mode
										8'hA1,  // SET_SEG_REMAP | 0xA1: column addr 127 mapped to SEG0
										8'hA8,  // SET_MUX_RATIO
										8'h3F,  // height - 1 (0x3F for 128x64 display)
										8'hC8,  // SET_COM_OUT_DIR
										8'hD3,  // SET_DISP_OFFSET
										8'h00,  // Display Y offset
										8'hDA,  // SET_COM_PIN_CFG
										8'h12,  // config for display
										8'hD5,  // SET_DISP_CLK_DIV
										8'h80,  // clock divide ratio
										8'hD9,  // SET_PRECHARGE
										8'hF1,  // value for internal VCC (0xF1 if self.external_vcc is False)
										8'hDB,  // SET_VCOM_DESEL
										8'h30,  // 0.83*Vcc
										8'h81,  // SET_CONTRAST
										8'hFF,  // maximum contrast
										8'hA4,  // SET_ENTIRE_ON: output follows RAM contents
										8'hA6,  // SET_NORM_INV: not inverted
										8'hAD,  // SET_IREF_SELECT
										8'h30,  // enable internal IREF during display on
										8'h8D,  // SET_CHARGE_PUMP
										8'h14,  // charge pump enable (0x14 if self.external_vcc is False)
										8'hAF,  // SET_DISP | 0x01: display on
										// Getting ready to draw
										8'h21,  // Set Column Address
										8'h00,  // Start column = 0
										8'h7F,  // End column = 127
										8'h22,  // Set Page Address
										8'h00,  // Start page = 0
										8'h07,  // End page = 7
										8'h00}; // THIS BYTE IS NOT SENT AT ALL, MERELY HERE TO REDUCE LOGIC COMPLEXITY

	I2C_Controller #(.SPEED(800)) i2c (.SCL(SCL), .busy(i2c_busy), .NACK(i2c_NACK), .data_saved(i2c_data_saved), .SDA_OUT(SDA_OUT), .SDA_IN(SDA_IN),
						.start(i2c_start), .clk(clk), .reset(reset), .send_additional_data(i2c_send_addit_data),
						.address_in(ADDRESS), .data_in(data_in), .sending_data(i2c_sending_data));
						
	enum {idle, init, sending_frame} state;
	
	assign busy = (state == idle) ? '0 : '1;
	assign data_address = index[9:0];
	assign get_next_data = i2c_data_saved || next_data_clk_lengthen || ((state == idle) && send_frame);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			NACK <= '0;
			i2c_start <= '0;
			state <= idle;
			index <= '0;
			data_in <= '0;
			i2c_send_addit_data <= '1;
			page01 <= '1;
		end
		else
		begin
			if (i2c_NACK) NACK <= '1;
			
			if (i2c_start) i2c_start <= '0;
			else if ((state == idle) && (init_display || send_frame)) i2c_start <= '1;
			
			unique case (state)
			idle : begin
				if (init_display)
				begin
					state <= init;
					data_in <= 8'h00;
				end
				else if (send_frame)
				begin
					state <= sending_frame;
					data_in <= 8'h40;
					page01 <= ~page01;
				end
				
				i2c_send_addit_data <= '1;
				index <= '0;
			end
			init :
				if (~i2c_busy && ~i2c_start) state <= idle;
				
			sending_frame : 
				if (~i2c_busy && ~i2c_start) state <= idle;
			endcase
		
			if (i2c_data_saved) //Asserted for a single clock cycle by the I2C controller
				case (state)
				init : begin
					data_in <= init_commands[index];
					if (index < `COMMAND_LENGTH)
						index <= index + 11'd1;
					else i2c_send_addit_data <= '0;
				end
						
				sending_frame : begin
					data_in <= frame_data;
					if (index < 11'd1024)
						index <= index + 11'd1;
					else i2c_send_addit_data <= '0;
				end
				endcase
		end
	end
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset) next_data_clk_lengthen <= '0;
		else if (i2c_data_saved) next_data_clk_lengthen <= '1;
		else if (next_data_clk_lengthen) next_data_clk_lengthen <= '0;
	end
endmodule
