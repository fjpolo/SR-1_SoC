`define CLK_FREQ 27000 //In KHz
//Only likely to support standard and fast modes as any faster sees the clock divider become too inaccurate
module I2C_Controller #(parameter SPEED = 400 /*in Kbps*/) (output logic SCL, busy, NACK, data_saved, sending_data, output tri SDA_OUT,
						input logic start, clk, reset, send_additional_data, SDA_IN,
						input logic [7:0] address_in, data_in);
	
	logic SDA_internal;
	logic [3:0] addrSent, dataSent;
	logic [7:0] address, data, clk_divider;
	
	enum {Idle, Start_SDA, Start_SCL, Address, Data, End_SCL, End_SDA} state;
	
	assign SDA_OUT = sending_data ? SDA_internal : 'z;
	
	always_ff @ (posedge clk, posedge reset)
	begin		
		if (reset) 
		begin 
			state <= Idle;
			address <= '0;
			data <= '0;
			addrSent <= '0;
			dataSent <= '0;
			clk_divider <= '0;
			data_saved <= '0;
		end
		else
		begin
			if ((state == Idle) && start)
			begin	
				state <= Start_SDA;
				address <= address_in; //LSB is write/read (write on low)
				data <= data_in;
				addrSent <= '0;
				dataSent <= '0;
				clk_divider <= '0;
				data_saved <= '1;
			end
				
			if (clk_divider == '0) begin
				case (state)
				Start_SDA : begin
					state <= Start_SCL;
					data_saved <= '0;
				end
				
				Start_SCL :state <= Address;
				
				Address : begin
					if (addrSent < 4'd8)
					begin
						address <= address << 8'd1;
						addrSent <= addrSent + 4'd1;
					end
					else if (addrSent == 4'd8) 
					begin 
						state <= Data;
						addrSent <= '0;
					end
				end
				
				Data : begin
					if (dataSent < 4'd8)
					begin
						data <= data << 8'd1;
						dataSent <= dataSent + 4'd1;
						data_saved <= '0;
					end
					else if (dataSent == 4'd8) 
					begin 
						if (~send_additional_data) state <= End_SCL;
						else 
						begin
							data <= data_in;
							data_saved <= '1;
						end
						dataSent <= '0;
					end
				end
				
				End_SCL : state <= End_SDA;
				
				End_SDA : state <= Idle;
				endcase
				
				clk_divider <= clk_divider + 8'd1;
			end
			else
			begin
				if(clk_divider < `CLK_FREQ / SPEED) clk_divider <= clk_divider + 8'd1;
				else clk_divider <= '0;
				
				if (data_saved) data_saved <= '0;
			end
		end
	end
	
	always_ff @ (posedge SCL, posedge reset)
	begin
		if (reset) NACK <= '0;
		else if ((addrSent == 4'd8) || (dataSent == 4'd8)) NACK <= SDA_IN;
		else NACK <= '0;
	end
	
	always_comb
	begin
		busy = '1;
		//Taken roughly 20% off start and 20% off the end, so clk duration clearly inside data (I2C requirement)
		SCL = (clk_divider > (2 * `CLK_FREQ / SPEED) / 10) && (clk_divider < (8 * `CLK_FREQ / SPEED) / 10);
		SDA_internal = '0;
		sending_data = '1;
		
		unique case (state)
		Idle : begin
			busy = '0;
			SCL = '1;
			SDA_internal = '1;
			sending_data = '0;
		end
		
		Start_SDA : SCL = '1;
		
		Start_SCL : SCL = '0;
		
		Address : begin
			if (addrSent < 8) SDA_internal = address[8'd7]; //Xmit MSB first
			else begin
				SDA_internal = '1;
				sending_data = '0;
			end
		end
		
		Data : begin
			if (dataSent < 8) SDA_internal = data[8'd7];
			else begin
				SDA_internal = '1;
				sending_data = '0;
			end
		end
		
		End_SCL : SCL = '1;
		
		End_SDA : begin
			SCL = '1;
			SDA_internal = '1;
		end
		
		endcase
	end
	
endmodule