//Algorithm from https://en.wikipedia.org/wiki/Double_dabble on 16/11/24
module DoubleDabbler (output logic [7:0] bcd_ascii_digits[5],
					output logic busy,
					input logic [15:0] data_bus, input logic start, clk, reset);
	
	logic [3:0] bcd4, bcd3, bcd2, bcd1, bcd0;
	logic [19:0] shift_reg;
	logic [15:0] data;
	logic [4:0] step;
	
	assign bcd_ascii_digits[0] = bcd0 + 8'd48; 
	assign bcd_ascii_digits[1] = bcd1 + 8'd48; 
	assign bcd_ascii_digits[2] = bcd2 + 8'd48; 
	assign bcd_ascii_digits[3] = bcd3 + 8'd48; 
	assign bcd_ascii_digits[4] = bcd4 + 8'd48;
	
	assign busy = (step != '0);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			shift_reg <= '0;
			data <= '0;
			step <= '0;
			bcd0 <= '0;
			bcd1 <= '0;
			bcd2 <= '0;
			bcd3 <= '0;
			bcd4 <= '0;
		end
		else if (clk)
		begin
			if (start) 
			begin
				step <= 5'd16;
				data <= data_bus;
				shift_reg <= '0;
			end
			else
				if (step > 0)
				begin
					shift_reg <= {shift_reg[18:0]
								+ (shift_reg[15:12] > 4'd4 ? 20'd12288 : 20'd0)
								+ (shift_reg[11:8]  > 4'd4 ? 20'd768 : 20'd0)
								+ (shift_reg[7:4]   > 4'd4 ? 20'd48 : 20'd0)
								+ (shift_reg[3:0]   > 4'd4 ? 20'd3 : 20'd0),
								data[step - 5'd1]};
					
					step <= step - 5'd1;
				end
				else
				begin
					bcd0 <= shift_reg[3:0];
					bcd1 <= shift_reg[7:4];
					bcd2 <= shift_reg[11:8];
					bcd3 <= shift_reg[15:12];
					bcd4 <= shift_reg[19:16];
				end
		end
	end
endmodule