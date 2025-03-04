module FP_Input_Pipe (output logic [17:0] mantissa,
					output logic [4:0] exponent,
					output logic sign,
					input logic [15:0] FP16);
	
	always_comb
	begin
		mantissa = {(|FP16[14:10]), FP16[9:0], 7'd0};
		exponent = FP16[14:10];
		sign = FP16[15];
	end
endmodule