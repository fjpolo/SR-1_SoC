module GPU_PC (inout tri [15:0] bus,
			input logic [12:0] counter_input,
			input logic [7:0] increment_amount,
			input clk, reset, set_pc, inc_pc, read_pc);
			
	logic [12:0] counter;
	
	assign bus = read_pc ? {3'd0, counter} : 'z;
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			counter <= '0;
		end
		else
		begin
			if (set_pc) counter <= counter_input;
			else if (inc_pc) counter <= counter + {5'd0, increment_amount};
		end
	end
endmodule