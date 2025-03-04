module FP_Output_Pipe (output logic [15:0] FP16,
					input logic [17:0] mantissa,
					input logic [4:0] exponent,
					input logic sign);
	
	logic [10:0] rounded_mantissa;
	logic round_up, overflow;
	
	always_comb
	begin
		round_up = mantissa[6]; //Round to nearest, ties to even
		rounded_mantissa = mantissa[16:7] + (round_up ? 10'd1 : '0);
		overflow = rounded_mantissa[10];
		
		FP16[15] = sign;
		FP16[14:10] = exponent + ((overflow && ~&exponent) ? 5'd1 : '0);
		FP16[9:0] = rounded_mantissa[9:0];
	end
endmodule