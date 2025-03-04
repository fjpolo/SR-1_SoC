module MAU (output logic busy,
			inout tri [15:0] data_bus_supr, data_bus_infr,
			input logic [15:0] matRAM,
			input logic start, mode, clk, reset, read_output);
			//0 for n*3, n*4 and 1 for n*2
	
	logic [35:0] mult_output;
	logic [18:0] mant_adder_output_internal;
	logic [17:0] acc_mant_regs [4];
	logic [17:0] mult_input_a, mult_input_b, mant_adder_a, mant_adder_b, mant_adder_output, shift_reg_mant, esc_mant_shift, msc_mant_shift, msc_input_mant;
	logic [15:0] a_reg, b_reg, c_reg, dbs_output, dbi_output;
	logic [4:0] acc_exp_regs [4];
	logic [4:0] exp_adder_output, exp_adder_a, exp_adder_b, esc_delta_exponent, esc_input_a, esc_input_b, msc_delta_exponent, msc_input_exp, cl_log;
	logic [4:0] shift_delta_exp, adjusted_log;
	logic acc_sign_regs [4];
	logic a_sign, b_sign, c_sign, mant_adder_a_sign, mant_adder_b_sign, mant_adder_output_sign, shift_2nd_value; //0 for 'a', 1 for 'b'
	logic esc_inverted_mode, exp_adder_mode;
	
	//See Miro flowchart for state details
	enum {idle, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13} state;
	
	assign a_sign = a_reg[15];
	assign b_sign = b_reg[15];
	assign c_sign = c_reg[15];
	
	assign data_bus_supr = (read_output && (state == idle)) ? dbs_output : 'z;
	assign data_bus_infr = (read_output && (state == idle) && mode) ? dbi_output : 'z;
	
	MULT18 mult0 (
        .dout(mult_output), //output [35:0] dout
        .a(mult_input_a), //input [17:0] a
        .b(mult_input_b) //input [17:0] b
    );
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			state <= idle;
			a_reg <= '0;
			b_reg <= '0;
			c_reg <= '0;
			
			//Accumulators
			acc_mant_regs[0] = '0;
			acc_mant_regs[1] = '0;
			acc_mant_regs[2] = '0;
			acc_mant_regs[3] = '0;
			
			acc_exp_regs[0] = '0;
			acc_exp_regs[1] = '0;
			acc_exp_regs[2] = '0;
			acc_exp_regs[3] = '0;
			
			acc_sign_regs[0] = '0;
			acc_sign_regs[1] = '0;
			acc_sign_regs[2] = '0;
			acc_sign_regs[3] = '0;
			
			shift_reg_mant <= '0;
			shift_delta_exp <= '0;
			shift_2nd_value <= '0;
		end
		else if (clk)
			case (state)
				idle : if (start) state <= s0;
				s0 : begin
					state <= s1;
					a_reg <= data_bus_supr;
					b_reg <= data_bus_infr;
					c_reg <= matRAM;
				end
				s1 : begin
					state <= s2;
					acc_mant_regs[0] <= mult_output[35:18];
					acc_exp_regs[0] <= exp_adder_output;
					acc_sign_regs[0] <= a_sign ^ c_sign;
					c_reg <= matRAM;
				end
				s2 : begin
					state <= s3;
					acc_mant_regs[1] <= mult_output[35:18];
					acc_exp_regs[1] <= exp_adder_output;
					acc_sign_regs[1] <= b_sign ^ c_sign;
					a_reg <= data_bus_supr;
					b_reg <= data_bus_infr;
					c_reg <= matRAM;
				end
				s3 : begin
					state <= s4;
					acc_mant_regs[2] <= mult_output[35:18];
					acc_exp_regs[2] <= exp_adder_output;
					acc_sign_regs[2] <= a_sign ^ c_sign;
					c_reg <= matRAM;
					//CALC SHIFT (A1 * C1.1) vs (B1 * C1.2)
					shift_reg_mant <= esc_mant_shift;
					shift_2nd_value <= esc_inverted_mode;
				end
				s4 : begin
					state <= s5;
					acc_mant_regs[shift_2nd_value] <= mult_output[34:17]; //SHIFT (A1 * C1.1) or (B1 * C1.2)
				end
				s5 : begin
					state <= s6;
					acc_mant_regs[3] <= mult_output[35:18];
					acc_exp_regs[3] <= exp_adder_output;
					acc_sign_regs[3] <= b_sign ^ c_sign;
					//ADD to E1
					acc_mant_regs[0] <= mant_adder_output;
					acc_exp_regs[0] <= shift_2nd_value ? acc_exp_regs[0] : acc_exp_regs[1];
					acc_sign_regs[0] <= mant_adder_output_sign;
					//CALC SHIFT (A2 * C2.1) vs (B2 * C2.2)
					shift_reg_mant <= esc_mant_shift;
					shift_2nd_value <= esc_inverted_mode;
				end
				s6 : begin
					state <= s7;
					acc_mant_regs[2'b10 | shift_2nd_value] <= mult_output[34:17]; //SHIFT (A2 * C2.1) or (B2 * C2.2)
					//CALC SHIFT (post ADD) E1
					shift_reg_mant <= msc_mant_shift;
					shift_delta_exp <= msc_delta_exponent;
				end
				s7 : begin
					state <= s8;
					//ADD to E2
					acc_mant_regs[1] <= mant_adder_output;
					acc_exp_regs[1] <= shift_2nd_value ? acc_exp_regs[2] : acc_exp_regs[3];
					acc_sign_regs[1] <= mant_adder_output_sign;
					acc_mant_regs[0] <= mult_output[17:0]; //SHIFT E1
					//EXP ADDITION (E2 - SHIFT)
					acc_exp_regs[0] <= exp_adder_output;
				end
				s8 : begin
					state <= s9;
					//CALC SHIFT (post ADD) E2
					shift_reg_mant <= msc_mant_shift;
					shift_delta_exp <= msc_delta_exponent;
				end
				s9 : begin
					if (mode) state <= idle;
					else state <= s10;
					acc_mant_regs[1] <= mult_output[17:0]; //SHIFT E2
					//EXP ADDITION (E2 - SHIFT)
					acc_exp_regs[1] <= exp_adder_output;
					//CALC SHIFT E1 vs (E2 - SHIFT)
					shift_reg_mant <= esc_mant_shift;
					shift_2nd_value <= esc_inverted_mode;
				end
				s10 : begin
					state <= s11;
					acc_mant_regs[shift_2nd_value] <= mult_output[34:17]; //SHIFT (E1 or E2)
				end
				s11 : begin
					state <= s12;
					//ADD to E3
					acc_mant_regs[0] <= mant_adder_output;
					acc_exp_regs[0] <= shift_2nd_value ? acc_exp_regs[0] : acc_exp_regs[1];
					acc_sign_regs[0] <= mant_adder_output_sign;
				end
				s12 : begin
					state <= s13;
					//CALC SHIFT (post ADD) E3
					shift_reg_mant <= msc_mant_shift;
					shift_delta_exp <= msc_delta_exponent;
				end
				s13 : begin
					state <= idle;
					acc_mant_regs[0] <= mult_output[17:0]; //SHIFT E3
					//EXP ADDITION (E3 - SHIFT)
					acc_exp_regs[0] <= exp_adder_output;
				end
			endcase
	end
	
	always_comb
	begin
		busy = '1;
		exp_adder_mode = '0;
		exp_adder_a = '0;
		exp_adder_b = '0;
		mult_input_a = '0;
		mult_input_b = '0;
		mant_adder_a = '0;
		mant_adder_a_sign = '0;
		mant_adder_b = '0;
		mant_adder_b_sign = '0;
		esc_input_a = '0;
		esc_input_b = '0;
		msc_input_exp = '0;
		msc_input_mant = '0;
		
		case (state)
			idle: busy = '0;
			
			//No s0
			
			s1 : begin
				mult_input_a = {(a_reg[14:10] != '0), a_reg[9:0], 7'b0};
				mult_input_b = {(c_reg[14:10] != '0), c_reg[9:0], 7'b0};
				
				exp_adder_a = a_reg[14:10];
				exp_adder_b = c_reg[14:10];
			end
			s2 : begin
				mult_input_a = {(b_reg[14:10] != '0), b_reg[9:0], 7'b0};
				mult_input_b = {(c_reg[14:10] != '0), c_reg[9:0], 7'b0};
				
				exp_adder_a = b_reg[14:10];
				exp_adder_b = c_reg[14:10];
			end
			s3 : begin
				mult_input_a = {(a_reg[14:10] != '0), a_reg[9:0], 7'b0};
				mult_input_b = {(c_reg[14:10] != '0), c_reg[9:0], 7'b0};
				
				exp_adder_a = a_reg[14:10];
				exp_adder_b = c_reg[14:10];
				
				esc_input_a = acc_exp_regs[0];
				esc_input_b = acc_exp_regs[1];
			end
			s4 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[shift_2nd_value];
			end
			s5 : begin
				mult_input_a = {(b_reg[14:10] != '0), b_reg[9:0], 7'b0};
				mult_input_b = {(c_reg[14:10] != '0), c_reg[9:0], 7'b0};
				
				exp_adder_a = b_reg[14:10];
				exp_adder_b = c_reg[14:10];
				
				mant_adder_a = acc_mant_regs[0];
				mant_adder_a_sign = acc_sign_regs[0];
				mant_adder_b = acc_mant_regs[1];
				mant_adder_b_sign = acc_sign_regs[1];
				
				esc_input_a = acc_exp_regs[2];
				esc_input_b = exp_adder_output;
			end
			s6 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[2'b10 | shift_2nd_value];
				
				msc_input_exp = acc_exp_regs[0];
				msc_input_mant = acc_mant_regs[0];
			end
			s7 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[0];
				
				exp_adder_a = acc_exp_regs[0];
				exp_adder_b = -shift_delta_exp;
				exp_adder_mode = '1;
				
				mant_adder_a = acc_mant_regs[2];
				mant_adder_a_sign = acc_sign_regs[2];
				mant_adder_b = acc_mant_regs[3];
				mant_adder_b_sign = acc_sign_regs[3];
			end
			s8 : begin
				msc_input_exp = acc_exp_regs[1];
				msc_input_mant = acc_mant_regs[1];
			end
			s9 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[1];
				
				exp_adder_a = acc_exp_regs[1];
				exp_adder_b = -shift_delta_exp;
				exp_adder_mode = '1;
				
				esc_input_a = acc_exp_regs[0];
				esc_input_b = exp_adder_output;
			end
			s10 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[shift_2nd_value];
			end
			s11 : begin
				mant_adder_a = acc_mant_regs[0];
				mant_adder_a_sign = acc_sign_regs[0];
				mant_adder_b = acc_mant_regs[1];
				mant_adder_b_sign = acc_sign_regs[1];
			end
			s12 : begin
				msc_input_exp = acc_exp_regs[0];
				msc_input_mant = acc_mant_regs[0];
			end
			s13 : begin
				mult_input_a = shift_reg_mant;
				mult_input_b = acc_mant_regs[0];
				exp_adder_a = acc_exp_regs[0];
				exp_adder_b = -shift_delta_exp;
				exp_adder_mode = '1;
			end
		endcase
	end
	
	always_comb
	begin : Exponent_Adder
		if ((exp_adder_a == '1) || ((exp_adder_b == '1) && ~exp_adder_mode))
			exp_adder_output = '1;
		else if (~(|mult_input_a && |mult_input_b))
			exp_adder_output = '0;
		else								//0-MULTIPLICATION MODE, 1-SHIFT MODE
			exp_adder_output = exp_adder_a + (exp_adder_b + (exp_adder_mode ? 5'd1 : -5'd14)); //Order to ensure no overflow
	end
	
	always_comb
	begin : Mantissa_Adder
		if (mant_adder_a_sign ^ mant_adder_b_sign)
			if (mant_adder_a > mant_adder_b) 
			begin 
				mant_adder_output_internal = mant_adder_a - mant_adder_b;
				mant_adder_output_sign = mant_adder_a_sign;
			end
			else
			begin 
				mant_adder_output_internal = mant_adder_b - mant_adder_a;
				mant_adder_output_sign = mant_adder_b_sign;
			end
		else
		begin 
			mant_adder_output_internal = mant_adder_a + mant_adder_b;
			mant_adder_output_sign = mant_adder_a_sign;
		end
		
		mant_adder_output = mant_adder_output_internal[18:1];
	end
	
	always_comb
	begin : Exponent_Shift_Calculator
		esc_inverted_mode = esc_input_a > esc_input_b;
		esc_delta_exponent = esc_inverted_mode ? (esc_input_a - esc_input_b) : (esc_input_b - esc_input_a);
		esc_mant_shift = (esc_delta_exponent > 5'd17) ? '0 : (18'b100000000000000000 >> esc_delta_exponent);
	end
	
	always_comb
	begin : Mantissa_Shift_Calculator
		adjusted_log = 5'd18 - cl_log;
		msc_delta_exponent = msc_input_exp > adjusted_log ? (adjusted_log) : msc_input_exp;
		msc_mant_shift = (msc_delta_exponent > 5'd18) ? '0 : (18'd1 << msc_delta_exponent);
	end
	
	CeilLogarithm #(.BASE_WIDTH(5), .INPUT_WIDTH(18), .MAX_WIDTH(32)) c_log0 (.log(cl_log), .num(msc_input_mant));
	
	MAU_OutputPipe mop0 (.fp16(dbs_output), .mantissa(acc_mant_regs[0]), .exponent(acc_exp_regs[0]), .sign(acc_sign_regs[0]));
	MAU_OutputPipe mop1 (.fp16(dbi_output), .mantissa(acc_mant_regs[1]), .exponent(acc_exp_regs[1]), .sign(acc_sign_regs[1]));
endmodule

module MAU_OutputPipe (output logic [15:0] fp16,
				input logic [17:0] mantissa,
				input logic [4:0] exponent,
				input logic sign);
	
	always_comb
	begin
		fp16 = {sign && |exponent && |mantissa[16:7], exponent, mantissa[16:7]};
	end
	
endmodule