module FP_ShiftUnit #(parameter M, E) (output logic [M - 1:0] shifted,
									output logic [E - 1:0] exp_shifted,
									input logic [M - 1:0] data,
									input logic [E - 1:0] exp);
									
	always_comb
	begin
		if ((exp != '0) && ~data[M - 1] && (data != '0))
		begin
			shifted = data << 1'd1;
			exp_shifted = exp - 1'd1;
		end
		else 
		begin
			shifted = data;
			exp_shifted = exp;
		end
	end

endmodule