module IM_Log18 (output logic [4:0] log,
				input logic [17:0] number);
	
	logic [17:0] streched_number;
	
	always_comb
	begin
		streched_number[17] = number[17];
		streched_number[16] = |number[17:16];
		streched_number[15] = |number[17:15];
		streched_number[14] = |number[17:14];
		streched_number[13] = |number[17:13];
		streched_number[12] = |number[17:12];
		streched_number[11] = |number[17:11];
		streched_number[10] = |number[17:10];
		streched_number[9] = |number[17:9];
		streched_number[8] = |number[17:8];
		streched_number[7] = |number[17:7];
		streched_number[6] = |number[17:6];
		streched_number[5] = |number[17:5];
		streched_number[4] = |number[17:4];
		streched_number[3] = |number[17:3];
		streched_number[2] = |number[17:2];
		streched_number[1] = |number[17:1];
		streched_number[0] = |number[17:0];
		
		log[4] = streched_number[15];
		
		log[3] = ^{streched_number[15],
				   streched_number[7]};
		
		log[2] = ^{streched_number[15], 
				   streched_number[11], 
				   streched_number[7], 
				   streched_number[3]};
				   
		log[1] = ^{streched_number[17], 
				   streched_number[15], 
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