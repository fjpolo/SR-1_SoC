module MAU_Multiplier (output logic [19:0] sum,
					output logic [4:0] exp_out,
					output logic sign,
					input logic [15:0] x_in, y_in,
					input logic set, clk, reset);
	
	logic [19:0] sum_internal;
	logic [15:0] a, b;
	logic [4:0] exp_delta;
	logic inverted_input, effectively_zero;
	
	assign inverted_input = (x_in[14:10] < y_in[14:10]);
	assign exp_delta = a[14:10] - b[14:10]);
	assign effectively_zero = exp_delta > 5'd17;
	assign exp_max = a[14:10];
	assign sign = (a[15] ^ b[15]) && ~effectively_zero;
	
	MULT10 mult0 (
        .dout(sum_internal), //output [19:0] dout
        .a(a[9:0]), //input [9:0] a
        .b(effectively_zero ? '0 : (b[9:0] >> exp_delta)) //input [9:0] b
    );

	FP_Shifter #(.M(20), .E(5)) fp_s0 (.mant_shifted(sum), .exp_shifted(exp_out),
									.mantissa(sum_internal), .exp(exp_max), .mantissa_overflow('0));	
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			a <= '0;
			b <= '0;
		end
		else if (clk)
			if (set) 
				if (inverted_input) 
				begin
					a <= y_in;
					b <= x_in;
				end
				else 
				begin
					a <= x_in;
					b <= y_in;
				end
			end
	end
endmodule