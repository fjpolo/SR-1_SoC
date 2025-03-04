`define PROG_LENGTH 32

import OpcodePackage::*;

module CPU_TB;
	logic [5:0] n_leds;
	logic SCL, SDA_OUT;
	logic [7:0] n_wide_sw_hi, n_wide_sw_lo, n_thin_sw;
	logic clk_in, n_reset, SDA_IN, n_enter_btn, n_l_btn, n_r_btn, n_t_btn, n_b_btn, n_p0_btn, n_p1_btn;
	
	CPU16 cpu (.*);
	
	initial
	begin
		n_wide_sw_hi = '1;
		n_wide_sw_lo = '1;
		n_thin_sw = '1;
		n_enter_btn = '1;
		n_l_btn = '1;
		n_r_btn = '1;
		n_t_btn = '1;
		n_b_btn = '1;
		n_p0_btn = '1;
		n_p1_btn = '1;
		SDA_IN = '0;
		clk_in = 0;
		n_reset = 1;
		#1ns n_reset = 0;
		#1ns n_reset = 1;
		forever #37ns clk_in = ~clk_in; //27MHz
	end
	
endmodule

//OLD PROGRAMS
/*//Fibonacci (PROG_LENGTH 32)
	logic [7:0] prog_to_load [`PROG_LENGTH] = '{
		'{'0}, 		//00
		'{8'(LDA)},	//01
		'{'0}, 		//02
		'{8'(LDB)}, //03
		'{'0}, 		//04
		'{8'(ADD)}, //05
		'{8'd30},	//06
		'{8'(LDA)}, //07
		'{8'd31}, 	//08
		'{8'(ADD)},	//09
		'{8'd29}, 	//10
		'{8'(BCD)},	//11
		'{8'd29}, 	//12
		'{8'(ADD)}, //13
		'{8'd30}, 	//14
		'{8'(LDB)}, //15
		'{8'd30},	//16
		'{8'(BCD)},	//17
		'{8'd30}, 	//18
		'{8'(JPC)}, //19
		'{'0}, 		//20
		'{8'(ADD)},	//21
		'{8'd29}, 	//22
		'{8'(LDA)}, //23
		'{8'd29}, 	//24
		'{8'(BCD)}, //25
		'{8'd29}, 	//26
		'{8'(JMP)}, //27
		'{8'd12}, 	//28
		'{'0}, 		//29
		'{'0}, 		//30
		'{8'd1} 	//31
	};
	
	//Mem Reset (PROG_LENGTH 13)
	logic [7:0] prog_to_load [`PROG_LENGTH] = '{
		'{'0}, 		//00
		'{8'(CPY)},	//01
		'{'0}, 		//02
		'{8'd13}, 	//03
		'{8'(LDA)}, //04
		'{8'd12}, 	//05
		'{8'(LDB)},	//06
		'{8'd3}, 	//07
		'{8'(ADD)},	//08
		'{8'd3}, 	//09
		'{8'(JMP)}, //10
		'{8'd0}, 	//11
		'{8'd1} 	//12
	};
	
	//Multiply B > A (PROG_LENGTH 32)
	logic [7:0] prog_to_load [`PROG_LENGTH] = '{
		'{8'd0},	//00
		'{8'(LDA)},	//01
		'{8'd0}, 	//02
		'{8'(LDB)}, //03
		'{8'd30},	//04
		'{8'(JPZ)}, //05
		'{8'd20},	//06
		'{8'(LDA)}, //07
		'{8'd29}, 	//08
		'{8'(LDB)},	//09
		'{8'd28}, 	//10
		'{8'(ADD)},	//11
		'{8'd28}, 	//12
		'{8'(LDA)}, //13
		'{8'd30}, 	//14
		'{8'(LDB)}, //15
		'{8'd31},	//16
		'{8'(SUB)},	//17
		'{8'd30}, 	//18
		'{8'(JMP)}, //19
		'{8'd0}, 	//20
		'{8'(BCD)},	//21
		'{8'd28}, 	//22
		'{8'(NXI)}, //23
		'{8'(HLT)},	//24
		'{8'd0},	//25
		'{8'd0},	//26
		'{8'd0},	//27
		'{8'd0}, 	//28
		'{8'd51},	//29
		'{8'd5},	//30
		'{8'd1} 	//31
	};
	
	//Up-down counter PROG_LENGTH = 31
	logic [7:0] prog_to_load [`PROG_LENGTH] = '{
		'{8'd0},
		'{8'd9},
		'{8'd0},
		'{8'd29},
		'{8'd2},
		'{8'd28},
		'{8'd8},
		'{8'd29},
		'{8'd1},
		'{8'd29},
		'{8'd3},
		'{8'd30},
		'{8'd7},
		'{8'd17},
		'{8'd3},
		'{8'd29},
		'{8'd5},
		'{8'd5},
		'{8'd8},
		'{8'd29},
		'{8'd1},
		'{8'd29},
		'{8'd4},
		'{8'd29},
		'{8'd6},
		'{8'd5},
		'{8'd5},
		'{8'd17},
		'{8'd1},
		'{8'd0},
		'{8'd0}
	};*/