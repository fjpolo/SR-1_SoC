module ALU (output logic [15:0] sum, 
			output logic cout, z, 
			input logic [15:0] a, b, 
			input logic subtract, mult, alu_and, alu_or, alu_xor, alu_not, half_mode, bytewise_mode, l_shift, r_shift);
	
	logic [35:0] mult_out;	
	logic [16:0] internal_sum; //Note extra carry bit!
	logic [15:0] a_internal, b_internal;
	logic a_or, b_or;
	
	assign sum = half_mode ? {8'd0, internal_sum[7:0]} : internal_sum[15:0];
	assign a_or = |a;
	assign b_or = |b;
	
	
	//Multiplier
	MULT18 mult0 (
	.dout(mult_out), //output [35:0] dout
	.a({2'd0, a}), //input [17:0] a
	.b({2'd0, b}) //input [17:0] b
	);
		
	always_comb
	begin
		internal_sum = '0;
		a_internal = a;
		b_internal = b;
	
		if (bytewise_mode)
		begin
			a_internal = {a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or, a_or};
			b_internal = {b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or, b_or};
		end
	
		//Addition/Subtraction
		if (subtract) internal_sum = a_internal - b_internal;
		else if (mult) internal_sum = {|mult_out[31:16], mult_out[15:0]};
		else if (alu_and) internal_sum = a_internal & b_internal;
		else if (alu_or) internal_sum = a_internal | b_internal;
		else if (alu_xor) internal_sum = a_internal ^ b_internal;
		else if (alu_not) internal_sum = ~a_internal;
		else if (l_shift) internal_sum = a << 16'd1;
		else if (r_shift) internal_sum = a >> 16'd1;
		else internal_sum = a_internal + b_internal;
		
		//Carry flag
		cout = half_mode ? (|internal_sum[16:8]) : internal_sum[16];
		
		//sum == 0 flag (does consider a high cout to be zero)
		z = (half_mode ? internal_sum[7:0] : internal_sum[15:0]) == '0;
	end
endmodule