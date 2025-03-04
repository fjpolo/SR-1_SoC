module FP_Shifter #(parameter M, E) (output logic [M - 1:0] mant_shifted,
									output logic [E - 1:0] exp_shifted,
									input logic [M - 1:0] mantissa,
									input logic [E - 1:0] exp,
									input logic mantissa_overflow);
	
	logic [M - 1:0] internal_shifts [M - 1:0];
	logic [M - 1:0] internal_mant_shifted;
	logic [E - 1:0] internal_exp [M - 1:0];
	logic [E - 1:0] internal_exp_shifted;
	logic mant_overflow_allowed;
	logic exp_overflow;
	
	assign exp_overflow = mantissa_overflow && ((exp | 1'd1) == '1);
	assign mant_overflow_allowed = mantissa_overflow && ((exp | 1'd1) < '1);
	assign internal_shifts[0] = mant_overflow_allowed ? {(exp != '0), mantissa[M-1:1]} : mantissa;
	assign internal_exp[0] = mant_overflow_allowed ? exp + 1'd1 : exp;
	assign mant_shifted = (exp == '1) ? mantissa : (exp_overflow ? '0 : internal_mant_shifted);
	assign exp_shifted = (exp_overflow || (exp == '1)) ? '1 : internal_exp_shifted;
	
	generate
		genvar i;
		
		for (i = 1; i < M; i++)
		begin : SHIFT_UNITS
			FP_ShiftUnit #(.M(M), .E(E)) fp_su0 (.shifted(internal_shifts[i]), .exp_shifted(internal_exp[i]),
												.data(internal_shifts[i-1]), .exp(internal_exp[i-1]));
		end
	endgenerate
	
	FP_ShiftUnit #(.M(M), .E(E)) fp_su1 (.shifted(internal_mant_shifted), .exp_shifted(internal_exp_shifted),
										.data(internal_shifts[M-1]), .exp(internal_exp[M-1]));

endmodule