module ROM16_CLK (
        output logic [23:0] dout, //output [15:0] dout
        input logic [3:0] ad //input [3:0] ad
    );
	
	logic [23:0] prog_to_load [16] = '{
		'{24'h000000}, 	//00 A	---------
		'{24'h000000},	//01 B	|A B C D|
		'{24'h000001},	//02 C	|E F G H|
		'{24'h000004},	//03 D	|I J K L|
		'{24'h000008}, 	//04 E	|M N O P|
		'{24'h000011}, 	//05 F	---------
		'{24'h00001D},	//06 G
		'{24'h00002C}, 	//07 H
		'{24'h00003B}, 	//08 I
		'{24'h000086},	//09 J
		'{24'h000545}, 	//10 K
		'{24'h0034BB},	//11 L
		'{24'h020F57}, 	//12 M
		'{24'h14996F}, 	//13 N
		'{24'h66FF2F}, 	//14 O
		'{24'hCDFE5F} 	//15 P
	};
	
	assign dout = prog_to_load[ad];
	
endmodule