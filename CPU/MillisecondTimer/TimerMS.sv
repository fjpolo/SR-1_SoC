module TimerMS #(parameter CLK_SPEED) (output logic waiting,
									input logic [15:0] repeats,
									input logic start, clk, reset);
									
	logic [15:0] reps_internal, counter;
	
	assign waiting = (|counter) || (|reps_internal);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			counter <= '0;
			reps_internal = '0;
		end
		else
			if (waiting)
			begin
				if (counter == 16'd0)
				begin
					counter <= (CLK_SPEED / 1000) - 16'd1;
					reps_internal <= reps_internal - 16'd1;
				end
				else
				begin
					counter <= counter - 16'd1;
				end
			end
			else if (start)
			begin
				counter <= (CLK_SPEED / 1000) - 16'd1;
				reps_internal <= repeats;
			end
	end
endmodule