module PC_TB; 
	tri [15:0] data_bus;
	logic increment, decrement, set, read, clk, reset, reset_instr;

	PC pc(.*);
	
	initial
	begin
		increment = '0;
		decrement = '0;
		set = '0;
		read = '0;
		clk = '0;
		reset = '0;
		
		for (int i = 0; i < 1000; i++)
		begin
			clk = !clk;
			#10ns;
			
			reset_instr = (i/2 == 32); 
			
			increment = (i > 3);
			
			decrement = (i > 240);
			
			read = (i % 3);
			
			$display("clk: %d, st: %d, inc: %d, dec: %d, rd: %d, db: %d", clk, set, increment, decrement, read, data_bus);
			
			#10ns;
		end
	end
endmodule
