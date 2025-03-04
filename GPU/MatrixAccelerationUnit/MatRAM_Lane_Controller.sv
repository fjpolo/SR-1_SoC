module MatRAM_Lane_Controller (output logic [9:0] address_out,
							input logic [9:0] address_in,
							input logic clk, reset, mau_start, set_address);
	
	logic [9:0] address;
	logic [1:0] counter;
	
	enum {idle, active, sync} state;
	
	assign address_out = address + counter;
			
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			state <= idle;
			address <= '0;
			counter <= '0;
		end
		else
			case (state)
				idle : begin
					if (set_address) address <= address_in;
					
					if (mau_start)
					begin
						state <= active;
						counter <= 2'd1;
					end
				end
				
				active : begin
					if (counter == 2'd1)
						state <= sync;
					if (counter == 2'd3)
					begin
						state <= idle;
						counter <= '0;
					end
					
					counter <= counter + 2'd1;
				end
				
				sync : state <= active;
			endcase
	end
endmodule