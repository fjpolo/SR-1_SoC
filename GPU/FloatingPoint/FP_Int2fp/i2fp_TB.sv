module i2fp_TB;

	logic [15:0] fp_num;
	logic [15:0] integer_num;

	FP_Int2fp i0 (.*);
	
	initial
	begin
		integer_num = 16'd12343;
		#10ns;
		integer_num = 16'd18343;
		#10ns;
		integer_num = 16'd32343;
		#10ns;
		integer_num = 16'd17;
		#10ns;
		integer_num = 16'd256;
		#10ns;
		integer_num = 16'd1;
		#10ns;
		integer_num = 16'd65535;
		#10ns;
	end

endmodule