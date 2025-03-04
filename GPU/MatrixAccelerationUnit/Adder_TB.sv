module MAU_Adder_TB;

	logic [17:0] c_mantissa;
	logic [4:0] c_exponent;
	logic c_sign;
	logic [17:0] a_mantissa, b_mantissa;
	logic [4:0] a_exponent, b_exponent;
	logic a_sign, b_sign, clk, reset, start;
				
	MAU_Adder add0 (.*);
	
	initial
	begin
		clk = '0;
		reset = '0;
		start = '1;
		#1ns reset = '1;
		#1ns reset = '0;
		forever #10ns clk = ~clk;
	end
	
	initial 
	begin
		a_mantissa = 18'b110111011100000000;
		b_mantissa = 18'b110111011010000000;
		a_exponent = 5'b01110;
		b_exponent = 5'b01110;
		a_sign = '0;
		b_sign = '1;
		#20ns start = '0;
	end
endmodule