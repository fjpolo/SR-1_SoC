module MAU_Adder #(parameter N) (output logic [N - 1:0] c,
								output logic c_sign,
								input logic [N - 2:0] a, b,
								input logic a_sign, b_sign);
	
	
	
	always_comb
	begin
		if (a_sign ^ b_sign)
		begin
			if (a > b)
			begin
				c = a - b;
				c_sign = a_sign;
			end
			else
			begin
				c = b - a;
				c_sign = b_sign;
			end
		end
		else
		begin
			c = a + b;
			c_sign = a_sign;
		end
	end
	
endmodule