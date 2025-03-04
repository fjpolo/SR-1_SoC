module FP_Adder #(parameter M, parameter E) (output logic [M - 1:0] c,
											output logic [E - 1:0] c_exp,
											output logic c_sign,
											input logic [M - 1:0] a, b,
											input logic [E - 1:0] a_exp, b_exp,
											input logic a_sign, b_sign, clk, set, reset);
	
	logic [M + 1:0] internal_sum;
	logic [M:0] x, y, shift_out;
	logic [E - 1:0] internal_exp, delta_exp;
	logic x_sign, y_sign, inverted_input;
	
	assign c = shift_out[M - 1:0];
	
	FP_Shifter #(.M(M + 1), .E(E)) fp_s0 (.mant_shifted(shift_out), .exp_shifted(c_exp),
									.mantissa(internal_sum[M:0]), .exp(internal_exp), .mantissa_overflow(internal_sum[M + 1]));
	
	assign inverted_input = a_exp < b_exp;
	assign delta_exp = inverted_input ? (b_exp - a_exp) : (a_exp - b_exp);
	
	always_comb
	begin
		if (x_sign ^ y_sign)
		begin
			if (x > y)
			begin
				internal_sum = x - y;
				c_sign = x_sign;
			end
			else
			begin
				internal_sum = y - x;
				c_sign = y_sign;
			end
		end
		else
		begin
			internal_sum = x + y;
			c_sign = x_sign;
		end
	end
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			x <= '0;
			y <= '0;
			x_sign <= '0;
			y_sign <= '0;
		end
		else if (clk)
			if (set)
			begin
				x_sign <= a_sign;
				y_sign <= b_sign;
				
				if (inverted_input)
				begin
					x <= {(a_exp != '0), a} >> delta_exp;
					y <= {(b_exp != '0), b};
					internal_exp <= b_exp;
				end
				else
				begin
					x <= {(a_exp != '0), a};
					y <= {(b_exp != '0), b} >> delta_exp;
					internal_exp <= a_exp;
				end
			end
	end
	
endmodule