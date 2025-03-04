module MAU #(parameter PRIMARY_OUTPUT) (output logic busy,
			inout tri [15:0] data_bus_supr, data_bus_infr,
			input logic [15:0] matRAM,
			input logic start, mode, clk, reset, read_output, add_mode);
			//0 for n*3, n*4 and 1 for n*2
	
	//Data
	logic [17:0] mult_a_m, mult_b_m, mult_out_m, buffer_m[2], add_out_m, add_in_m;
	logic [15:0] db_input_buffer[2], db_input, dbs_output, dbi_output, dbs, dbi;
	logic [4:0] mult_a_e, mult_b_e, mult_out_e, buffer_e[2], add_out_e, add_in_e;
	logic [3:0] time_waited;
	logic mult_a_s, mult_b_s, mult_out_s, buffer_s[2], add_out_s, add_in_s;
	
	//Control
	logic start_add;
	logic write_dbs, write_dbi; //Write to data buses
	
	//See Miro flowchart for state details
	enum {idle, mult1, mult2, add1, mult3, mult4, add2, add2_result, add3, add3_result, waiting} state;
	
	assign data_bus_supr = write_dbs ? dbs : 'z;
	assign data_bus_infr = write_dbi ? dbi : 'z;
	
	FP_Input_Pipe in0 (
		.mantissa(mult_a_m),
		.exponent(mult_a_e),
		.sign(mult_a_s),
		.FP16(db_input)
	);
	
	FP_Input_Pipe in1 (
		.mantissa(mult_b_m),
		.exponent(mult_b_e),
		.sign(mult_b_s),
		.FP16(matRAM)
	);
	
	MAU_Multiplier m_mult0 (
		.c_mantissa(mult_out_m),
		.c_exponent(mult_out_e),
		.c_sign(mult_out_s),
		.a_mantissa(mult_a_m),
		.b_mantissa(mult_b_m),
		.a_exponent(mult_a_e),
		.b_exponent(mult_b_e),
		.a_sign(mult_a_s),
		.b_sign(mult_b_s)
	);
	
	MAU_Adder m_add0 (
		.c_mantissa(add_out_m),
		.c_exponent(add_out_e),
		.c_sign(add_out_s),
		.a_mantissa(buffer_m[0]),
		.b_mantissa(add_in_m),
		.a_exponent(buffer_e[0]),
		.b_exponent(add_in_e),
		.a_sign(buffer_s[0]),
		.b_sign(add_in_s),
		.clk(clk), 
		.reset(reset), 
		.start(start_add)
	);
	
	FP_Output_Pipe out0 (
		.FP16(dbs_output),
		.mantissa(buffer_m[0]),
		.exponent(buffer_e[0]),
		.sign(buffer_s[0])
	);
	
	FP_Output_Pipe out1 (
		.FP16(dbi_output),
		.mantissa(buffer_m[1]),
		.exponent(buffer_e[1]),
		.sign(buffer_s[1])
	);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset) 
		begin
			state <= idle;
			db_input_buffer[0] <= '0;
			db_input_buffer[1] <= '0;
			time_waited <= '0;
			
			buffer_m[0] <= '0;
			buffer_e[0] <= '0;
			buffer_s[0] <= '0;
			
			buffer_m[1] <= '0;
			buffer_e[1] <= '0;
			buffer_s[1] <= '0;
		end
		else
			case (state)
				idle : begin
					if (start) state <= mult1;
					time_waited <= '0;
				end
				
				mult1 : begin
					state <= mult2;
					db_input_buffer[0] <= data_bus_supr;
					db_input_buffer[1] <= data_bus_infr;
					buffer_m[0] <= mult_out_m;
					buffer_e[0] <= mult_out_e;
					buffer_s[0] <= mult_out_s;
				end
				
				mult2 : begin
					state <= add1;
					buffer_m[1] <= mult_out_m;
					buffer_e[1] <= mult_out_e;
					buffer_s[1] <= mult_out_s;
				end
				
				add1 : begin
					state <= mult3;
				end
				
				mult3 : begin
					state <= mult4;
					if (~mode || add_mode) db_input_buffer[1] <= data_bus_infr;
					buffer_m[0] <= mult_out_m;
					buffer_e[0] <= mult_out_e;
					buffer_s[0] <= mult_out_s;
				end
				
				mult4 : begin
					state <= waiting;
					buffer_m[1] <= mult_out_m;
					buffer_e[1] <= mult_out_e;
					buffer_s[1] <= mult_out_s;
				end
				
				add2 : begin
					state <= waiting;
					buffer_m[0] <= add_out_m; //Saving previous addition
					buffer_e[0] <= add_out_e;
					buffer_s[0] <= add_out_s;
				end
				
				add2_result : begin
					state <= idle;
					buffer_m[1] <= add_out_m; //Saving previous addition
					buffer_e[1] <= add_out_e;
					buffer_s[1] <= add_out_s;
				end
				
				add3 : begin
					state <= waiting;
				end
				
				add3_result : begin
					state <= idle;
					buffer_m[0] <= add_out_m;
					buffer_e[0] <= add_out_e;
					buffer_s[0] <= add_out_s;
				end
				
				waiting : begin
					time_waited <= time_waited + 4'd1;
					
					if (time_waited == 4'd0) state <= add2;
					if (time_waited == 4'd3) 
						if (mode) state <= add2_result; 
						else state <= add3;
					if (time_waited == 4'd6) state <= add3_result;
				end
			endcase
	end
	
	always_comb
	begin
		busy = '1;
		db_input = data_bus_supr;
		add_in_m = buffer_m[1];
		add_in_e = buffer_e[1];
		add_in_s = buffer_s[1];
		start_add = '0;
		write_dbs = '0;
		write_dbi = '0;
		
		case(state)
			idle : busy = '0;
			
			mult2 : begin
				db_input = db_input_buffer[1];
			end
			
			add1 : begin
				start_add = '1;
			end
			
			mult3 : begin
				if (mode && ~add_mode) db_input = db_input_buffer[0];
			end
			
			mult4 : begin
				db_input = db_input_buffer[1];
			end
			
			add2 : begin
				start_add = '1;
			end
			
			add3 : begin
				start_add = '1;
				add_in_m = add_out_m;
				add_in_e = add_out_e;
				add_in_s = add_out_s;
			end
			
			//No other cases needed
		endcase
		
		//Outputs
		dbs = dbs_output;
		
		if (PRIMARY_OUTPUT == "dbs")
		begin
			dbi = dbi_output;
			
			if (read_output)
			begin
				write_dbs = '1;
				
				if (mode) write_dbi = '1;
			end
		end
		else if (PRIMARY_OUTPUT == "dbi")
		begin
			dbi = mode ? dbi_output : dbs_output;
			
			if (read_output)
			begin
				if (mode) 
				begin
					write_dbs = '1;
					write_dbi = '1;
				end
				else write_dbi = '1;
			end
		end
	end
endmodule