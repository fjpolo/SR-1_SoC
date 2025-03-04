module FP_AdderTB; 
	logic [9:0] c;
	logic [4:0] c_exp;
	logic c_sign;
	logic [9:0] a, b;
	logic [4:0] a_exp, b_exp;
	logic a_sign, b_sign, clk, set, reset;
			
	FP_Adder #(.M(10), .E(5)) fp_a0 (.*);
			
	initial
	begin
		a = 10'b1011100111;
		b = 10'b1011101001;
		a_exp = 5'b10010;
		b_exp = 5'b10010;
		a_sign = '1;
		b_sign = '0;
	
		clk = '0;
		set = '0;
		reset = '0;
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #5ns clk = ~clk;
	end
	
	initial
	begin
		#15ns set = '1;
		#10ns set = '0;
		
		a = 10'b0011001101;
		b = 10'b1001001000;
		a_exp = 5'b01111;
		b_exp = 5'b10000;
		a_sign = '0;
		b_sign = '0;
		
		#15ns set = '1;
		#10ns set = '0;
		
		a = 10'b0011001101;
		b = 10'b1001001000;
		a_exp = 5'b11111;
		b_exp = 5'b10000;
		a_sign = '0;
		b_sign = '0;
		
		#15ns set = '1;
		#10ns set = '0;
	end
endmodule