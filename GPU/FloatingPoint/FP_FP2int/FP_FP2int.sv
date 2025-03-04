module FP_FP2int (output logic [15:0] integer_num,
				input logic [15:0] fp_num);
	
	logic [35:0] shift_out;
	logic [15:0] shift, shift_adjusted;
	logic [4:0] exp_unbiased;
	logic [3:0] address;
	
	//Shift lookup
	ROM16_FP2I shift_lut0 (
        .dout(shift), //output [15:0] dout
        .ad(address) //input [3:0] ad
    );
	
	//Shifting
	MULT18 shift_mult0 (
        .dout(shift_out), //output [35:0] dout
        .a({2'd0, shift_adjusted}), //input [17:0] a
        .b({7'd0, (|fp_num[14:10]), fp_num[9:0]}) //input [17:0] b
    );
	
	always_comb
	begin
		if (fp_num[14:10] > 5'd14)
			exp_unbiased = fp_num[14:10] - 5'd14;
		else
			exp_unbiased = '0;
		
		if (exp_unbiased > 5'd15)
			address = '0;
		else 
			address = exp_unbiased[3:0];
		
		shift_adjusted = shift | {(exp_unbiased == 5'd16) ,15'd0};
		
		integer_num = shift_out[25:10]; //SIGN IGNORED
	end
endmodule