module PC (output logic [15:0] db_out,
		input logic [15:0] data_bus,
		input logic increment, decrement, set, reset_on_clk, read, clk, reset, dual_op);
	
	logic [15:0] counter = '0;
	
	assign db_out = read ? counter : '0;
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset) counter <= '0;
		else if (clk)
		begin
			
			if (dual_op)
			begin
				if (increment) counter <= counter + 16'd2;
				if (decrement) counter <= counter - 16'd2;
			end
			else
			begin
				if (increment) counter <= counter + 16'd1;
				if (decrement) counter <= counter - 16'd1;
			end
			
			if (set) counter <= data_bus;
			
			if (reset_on_clk) counter <= '0;
		end
	end	
endmodule
