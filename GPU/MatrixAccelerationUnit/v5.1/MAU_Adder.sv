module MAU_Adder (output logic [17:0] c_mantissa,
				output logic [4:0] c_exponent,
				output logic c_sign,
				input logic [17:0] a_mantissa, b_mantissa,
				input logic [4:0] a_exponent, b_exponent,
				input logic a_sign, b_sign, clk, reset, start);
	
	logic [35:0] mult_output;
	logic [17:0] large_m, value, shift, adder_output;
	logic [4:0] large_e, log_output, adjusted_log, delta_exponent;
	logic large_s, small_s, adder_output_sign, adder_overflow, full_shift, a_exp_grtr_b_exp;
	
	enum {load, preshift, add, postshift} state;
	
	MULT18 mult0 (
        .dout(mult_output), //output [35:0] dout
        .a(value), //input [17:0] a
        .b(shift) //input [17:0] b
    );
	
	MAU_Mantissa_Adder add0 (
		.sum(adder_output),
		.sum_sign(adder_output_sign),
		.overflow(adder_overflow),
		.a(large_m),
		.a_sign(large_s),
		.b(value),
		.b_sign(small_s)
	);
	
	MAU_LOG18 log0 (
		.log(log_output),
		.number(adder_output)
	);
	
	assign adjusted_log = 5'd18 - log_output;
	assign full_shift = (large_e > adjusted_log);
	assign a_exp_grtr_b_exp = a_exponent > b_exponent;
	assign delta_exponent =  a_exp_grtr_b_exp ? (a_exponent - b_exponent) : (b_exponent - a_exponent);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			state <= load;
			large_m <= '0;
			large_e	<= '0;
			large_s <= '0;
			small_s <= '0;
			value <= '0;
			shift <= '0;
			
			c_mantissa <= '0;
			c_exponent <= '0;
			c_sign <= '0;
		end
		else if (clk)
		begin
			case (state)
				load : begin
					if (start) begin
						state <= preshift;
						shift <= (delta_exponent < 18'd18) ? (18'b100000000000000000 >> delta_exponent) : '0;
						
						if (a_exp_grtr_b_exp) begin
							large_m <= a_mantissa;
							large_e <= a_exponent;
							large_s <= a_sign;
							small_s <= b_sign;
							value <= b_mantissa;
						end else begin
							large_m <= b_mantissa;
							large_e <= b_exponent;
							large_s <= b_sign;
							small_s <= a_sign;
							value <= a_mantissa;
						end
					end
				end
				
				preshift : begin
					state <= add;
					value <= mult_output[34:17];
				end
				
				add : begin
					state <= postshift;
					value <= adder_output;
					c_sign <= adder_output_sign;
					
					c_exponent <= adder_overflow ? (large_e + 5'd1) : (full_shift ? (large_e - adjusted_log) : '0);
					shift <= 18'd1 << (adder_overflow ? '0 : (full_shift ? adjusted_log : large_e));
				end
				
				postshift : begin
					state <= load;
					c_mantissa <= mult_output[17:0];
				end
			endcase
		end
	end
endmodule

module MAU_Mantissa_Adder (output logic [17:0] sum,
						output logic sum_sign, overflow,
						input logic [17:0] a, b,
						input logic a_sign, b_sign);
	
	logic [18:0] sum_internal;
	
	always_comb
	begin
		if (a_sign ^ b_sign)
			if (a > b) 
			begin 
				sum_internal = a - b;
				sum_sign = a_sign;
			end
			else
			begin 
				sum_internal = b - a;
				sum_sign = b_sign;
			end
		else
		begin 
			sum_internal = a + b;
			sum_sign = a_sign;
		end
		
		overflow = sum_internal[18];
		sum = overflow ? sum_internal[18:1] : sum_internal[17:0];
	end
endmodule