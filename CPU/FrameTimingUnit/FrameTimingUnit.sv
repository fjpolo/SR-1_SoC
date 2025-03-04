module FrameTimingUnit (output logic send_frame,
						input logic clk, reset, clk_pre);
						
	logic [18:0] counter;
	logic passed_zero, recieved_passed_zero;
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			counter <= '0;
			passed_zero <= '1;
		end
		else
		begin
			if (counter == 19'd449999)
				counter <= '0;
			else
				counter <= counter + 19'd1;
				
			if (recieved_passed_zero)
				passed_zero <= '0;
			else if (counter == '0)
				passed_zero = '1;
		end
	end
	
	always_ff @ (posedge clk_pre, posedge reset)
	begin
		if (reset)
		begin
			send_frame <= '0;
			recieved_passed_zero <= '0;
		end
		else
		begin
			if (passed_zero)
			begin
				send_frame <= '1;
				recieved_passed_zero <= '1;
			end
			else
			begin
				send_frame <= '0;
				recieved_passed_zero <= '0;
			end
		end
	end
endmodule