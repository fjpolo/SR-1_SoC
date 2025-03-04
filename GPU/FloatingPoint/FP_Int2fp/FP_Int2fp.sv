module FP_Int2fp (output logic [15:0] fp_num,
				input logic [15:0] integer_num);
	
	logic [35:0] shift_out;
	logic [15:0] shift;
	logic [4:0] log, address;
	
	IM_Log16 log_0 (
		.log(log),
		.number(integer_num)
	);
	
	//Shift lookup
	ROM16_I2FP shift_lut0 (
        .dout(shift), //output [15:0] dout
        .ad(address[3:0]) //input [3:0] ad
    );
	
	//Shifting
	MULT18 shift_mult0 (
        .dout(shift_out), //output [35:0] dout
        .a({2'd0, shift}), //input [17:0] a
        .b({2'd0, integer_num}) //input [17:0] b
    );
	
	always_comb
	begin
		address = log - 5'd1;
	
		fp_num[15] = 0;
		fp_num[14:10] = (|log) ? (log + 5'd14) : '0;
		fp_num[9:0] = shift_out[14:5]; //NOT ROUNDED - Not quite as accurate, but need to save resources for now. Can always change later
	end
	
endmodule