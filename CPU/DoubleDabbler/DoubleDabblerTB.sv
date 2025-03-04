module DoubleDabblerTB;
	logic [7:0] bcd_ascii_digits [5];
	logic [15:0] data_bus;
	logic start, clk, reset;
	
	DoubleDabbler dubdab(.*);
	
	initial
	begin
		start = '0;
		clk = '0;
		reset = '0;
		
		for (int j = 0; j < 10; j++)
		begin
			assign data_bus = $urandom(data_bus + 2);
			for (int i = 0; i < 48; i++)
			begin
				start = (i / 2 == 2);
				
				#10ns;
				clk = !clk;
				#10ns;
			end
		end
	end
	
endmodule
