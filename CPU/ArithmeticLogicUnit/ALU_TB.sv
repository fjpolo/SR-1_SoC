module ALU_TB;
	logic [15:0] sum;
	logic cout, z;
	logic [15:0] a, b;
	logic subtract, mult, alu_and, alu_or, alu_xor, alu_not, half_mode, bytewise_mode, l_shift, r_shift;
	
	ALU alu0 (.*);

	initial
	begin
		subtract = '0;
		mult = '0;
		alu_and = '0;
		alu_or = '0;
		alu_xor = '0;
		alu_not = '0;
		half_mode = '0;
		bytewise_mode = '0;
		l_shift = '0;
		r_shift = '0;
		
		//TESTING ARITHMETIC
		a = 16'd2556;
		b = 16'd44433;
		#10ns;
		half_mode = '1;
		#10ns;
		half_mode = '0;
		a = 16'd44433;
		b = 16'd2556;
		subtract = '1;
		#10ns;
		subtract = '0;
		mult = '1;
		a = 16'd212;
		b = 16'd102;
		#10ns;
		mult = '0;
		
		//TESTING BITWISE
		a = 16'b1001000111110000;
		b = 16'b1111000001011010;
		alu_and = '1;
		#10ns;
		alu_and = '0;
		alu_or = '1;
		#10ns;
		alu_or = '0;
		alu_xor = '1;
		#10ns;
		alu_xor = '0;
		alu_not = '1;
		#10ns;
		alu_not = '0;
		
		//TESTING BYTEWISE
		a = 16'b1001000111110000;
		b = '0;
		bytewise_mode = '1;
		alu_and = '1;
		#10ns;
		alu_and = '0;
		alu_or = '1;
		#10ns;
		alu_or = '0;
		alu_xor = '1;
		#10ns;
		alu_xor = '0;
		alu_not = '1;
		#10ns;
		alu_not = '0;
		
		//TESTING SHIFTS
		bytewise_mode = '0;
		l_shift = '1;
		#10ns;
		l_shift = '0;
		r_shift = '1;
		#10ns;
		r_shift = '0;
		#10ns;
	end
endmodule
