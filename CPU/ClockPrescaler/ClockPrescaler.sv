module ClockPrescaler (output logic clk_out,
					input [7:0] scale, input logic clk_hw, reset, enable);
	
	logic [23:0] counter, top_value;
	
	logic clk_div;
	
	ROM16_CLK prescale_tops (
        .dout(top_value), //output [23:0] dout
        .ad(scale[3:0]) //input [3:0] ad
    );
	
	always_ff @ (posedge clk_hw, posedge reset)
	begin
		if (reset)
		begin
			counter <= '0;
			clk_div <= '0;
		end
		else
			if (counter >= top_value)
			begin
				clk_div <= ~clk_div;
				counter <= '0;
			end
			else counter <= counter + 24'd1;
	end
	
	always_comb
	begin
		if (scale == '0)
			clk_out = clk_hw;
		else
			clk_out = clk_div;
	end
endmodule