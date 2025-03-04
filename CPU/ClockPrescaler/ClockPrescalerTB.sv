module ClockPrescalerTB;
					logic [7:0] scale;
					logic clk_out;
					logic clk_hw, reset, enable;
					
	ClockPrescaler clkpre (.*);
	
	initial
	begin
		clk_hw = 0;
		enable = 1;
		reset = 1;
		#10ns reset = 0;
		
		forever #10ns clk_hw = ~clk_hw;
	end
	
	initial
	begin
		for (int i = 0; i < 16; i++)
		begin
			scale = i;
			#10us;
		end
		#2.5s;
		$stop;
	end
	
endmodule
