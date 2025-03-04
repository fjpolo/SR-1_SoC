module RAM (output logic [7:0] mm_prescale, mem_do,
			input logic [7:0] mem_di, sw1, sw2, btn1,
			input logic [14:0] address, 
			input logic read, write, mem_clk, mem_reset);
			
			//RAM IS 32768B (2^15 addresses)
			//Special Addresses:
			//7FFF : Clock prescaler
			//7FFE : DIP switches 1
			//7FFD : DIP switches 2
			//7FFC : Push buttons 1
	
	logic [7:0] dout;
	
	BSRAM bsram0 (
        .dout(dout), //output [7:0] dout
        .clk(clk), //input clk
        .oce('0), //input oce (invalid in bypass, which is the mode it is in)
        .ce(read | write), //input ce
        .reset(mem_reset), //input reset
        .wre(write), //input write enable
        .ad(address), //input [14:0] ad
        .din(mem_di) //input [7:0] din
    );

	always_ff @ (posedge mem_clk, posedge mem_reset)
		if (mem_reset)
		begin
			mm_prescale <= 8'd0;
		end
		else if (write && address == 15'h7FFF) mm_prescale <= mem_di;
		
	always_comb
	begin
		if (address == 15'h7FFF) mem_do = mm_prescale;
		else if (address == 15'h7FFE) mem_do = sw1;
		else if (address == 15'h7FFD) mem_do = sw2;
		else if (address == 15'h7FFC) mem_do = btn1;
		else mem_do = dout;
	end
	
endmodule