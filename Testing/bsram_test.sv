module bsram_test #(parameter A_SIZE, DEPTH, W_SIZE) (output logic [W_SIZE-1:0] doutb, douta,
													input logic [A_SIZE-1:0] addra, addrb,
													input logic [W_SIZE-1:0] dina, dinb,
													input logic clk, reset, wra, wrb, cea, ceb);
	
	logic [W_SIZE-1:0] data [DEPTH];
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			douta <= '0;
			doutb <= '0;
		end
		else if (clk)
		begin
			if (~wra && cea) douta <= data[addra];
			if (~wrb && ceb) doutb <= data[addrb];
			
			if (wra && cea) data[addra] <= dina;
			if (wrb && ceb) data[addrb] <= dinb;
		end
	end
endmodule