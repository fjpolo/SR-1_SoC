module IM_Log16 (output logic [4:0] log,
				input logic [15:0] number);
	
	logic [15:0] streched_number;
	
	always_comb
	begin
		streched_number[15] = |number[15];
		streched_number[14] = |number[15:14];
		streched_number[13] = |number[15:13];
		streched_number[12] = |number[15:12];
		streched_number[11] = |number[15:11];
		streched_number[10] = |number[15:10];
		streched_number[9] = |number[15:9];
		streched_number[8] = |number[15:8];
		streched_number[7] = |number[15:7];
		streched_number[6] = |number[15:6];
		streched_number[5] = |number[15:5];
		streched_number[4] = |number[15:4];
		streched_number[3] = |number[15:3];
		streched_number[2] = |number[15:2];
		streched_number[1] = |number[15:1];
		streched_number[0] = |number[15:0];
		
		log[4] = streched_number[15];
		
		log[3] = ^{streched_number[15],
				   streched_number[7]};
		
		log[2] = ^{streched_number[15], 
				   streched_number[11], 
				   streched_number[7], 
				   streched_number[3]};
				   
		log[1] = ^{streched_number[15], 
				   streched_number[13], 
				   streched_number[11], 
		           streched_number[9], 
				   streched_number[7], 
				   streched_number[5], 
				   streched_number[3], 
				   streched_number[1]};
				   
		log[0] = ^streched_number;
	end
endmodule