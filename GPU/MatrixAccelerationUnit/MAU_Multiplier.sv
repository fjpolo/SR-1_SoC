module MAU_Multiplier (output logic [17:0] c_mantissa,
					output logic [4:0] c_exponent,
					output logic c_sign,
					input logic [17:0] a_mantissa, b_mantissa,
					input logic [4:0] a_exponent, b_exponent,
					input logic a_sign, b_sign);
	
	logic [35:0] mult_output;
	logic [5:0] reduced_exp, initial_exp;
	logic very_small;
	
	MULT18 mult0 (
        .dout(mult_output), //output [35:0] dout
        .a(a_mantissa), //input [17:0] a
        .b(b_mantissa) //input [17:0] b
    );
	
	always_comb
	begin
		initial_exp = a_exponent + b_exponent;
		very_small = (initial_exp < 5'd14);
		reduced_exp = initial_exp - 5'd14;
		
		c_mantissa = mult_output[35:18];
		c_exponent = (reduced_exp[5] || very_small) ? (very_small ? '0 : '1) : reduced_exp[4:0];
		c_sign = a_sign ^ b_sign;
	end
endmodule