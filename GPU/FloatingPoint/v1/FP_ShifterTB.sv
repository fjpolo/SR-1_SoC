module FP_ShifterTB;

	logic [9:0] mant_shifted;
	logic [4:0] exp_shifted;
	logic [9:0] mantissa;
	logic [4:0] exp;
	//logic clk, set, reset;
	logic mantissa_overflow;
											
	FP_Shifter #(.M(10), .E(5)) fps0 (.*);
	
	initial
	begin
		mantissa = 10'b0011100100;
		mantissa_overflow = '0;
		exp = 5'd5;
		#10ns;
		mantissa = 10'b0011100000;
		mantissa_overflow = '0;
		exp = 5'd5;
		#10ns;
		mantissa = 10'b0011100101;
		mantissa_overflow = '1;
		exp = 5'd31;
		#10ns;
		mantissa = 10'b0011100100;
		mantissa_overflow = '1;
		exp = 5'd30;
		#10ns;
		mantissa = 10'b0011100100;
		mantissa_overflow = '1;
		exp = 5'd25;
		#10ns;
		mantissa = 10'b0010000001;
		mantissa_overflow = '1;
		exp = 5'd25;
		#10ns;
		mantissa = 10'b0000010001;
		mantissa_overflow = '0;
		exp = 5'd3;
		mantissa = 10'b0000000000;
		mantissa_overflow = '1;
		exp = 5'd0;
		#10ns;
		mantissa = 10'b0000000000;
		mantissa_overflow = '0;
		exp = 5'd0;
		#10ns;
	end
endmodule