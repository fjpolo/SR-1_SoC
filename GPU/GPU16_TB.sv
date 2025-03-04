`define DATA_LENGTH 28

module GPU16_TB; 

	logic [15:0] gpu_data_reg, fp_to_int;
	logic SDA_OUT, SCL, busy;
	logic [15:0] int_to_fp, cpu_data;
	logic [12:0] gpc_val_s, gpc_val_i;
	logic [7:0] gpc_inc_amount_a, gpc_inc_amount_b, repeat_op_amount;
	logic [4:0] instruction;
	logic clk, reset, SDA_IN, gpu_start;
	
	logic [15:0] data_to_load [`DATA_LENGTH] = '{
		'{16'b0011110000000000}, //1
		'{16'b0100000000000000}, //2
		'{16'b0100001000000000}, //3
		'{16'b0100010000000000}, //4
		'{16'b0100010100000000}, //5
		'{16'b0100011000000000}, //6
		'{16'b0100011100000000}, //7
		'{16'b0100100000000000}, //8
		'{16'b0010111001100110}, //0.1
		'{16'b0011001001100110}, //0.2
		'{16'b0100101110000000}, //15
		'{16'b0101101100001000}, //225
		'{16'b1101110010110000}, //-300
		'{16'b0101101101000000}, //232
		'{16'b0101000110000000}, //44
		'{16'b1010000100011111}, //-0.01
		'{16'b0100101000000000}, //12
		'{16'b0100100000000000}, //8
		'{16'b0110011111010110}, //2006
		'{16'b0100110010000000}, //18
		'{16'b1100001000000000}, //-3
		'{16'b1100011100000000}, //-7
		'{16'b0100010000000000}, //4
		'{16'b0100100010000000}, //9
		'{16'b0011110000000000}, //1
		'{16'b0100001001001000}, //3.14159
		'{16'b0011110000000000}, //1
		'{16'b0100110001001111}  //17.23
	};
			
	GPU16 gpu0 (.*);
	
	initial
	begin
		int_to_fp = '0;
		cpu_data = '0;
		gpc_val_s = '0;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		repeat_op_amount = '0;
		instruction = 5'd1;
		clk = '0;
		reset = '0;
		SDA_IN = '0;
		gpu_start = '0;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #10ns clk = ~clk;
	end
	
	initial
	begin
		#7ns;
		
		//LOADING VRAM
		for (int i  = 0; i < `DATA_LENGTH; i++)
		begin
		gpc_val_s = i;
		cpu_data = data_to_load[i];
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		#60ns;
		end
		
		//LOADING MRAM FROM VRAM
		gpc_val_s = '0;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd4;
		repeat_op_amount = 8'd7;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#800ns;
		
		//2 4x4 by 4x1 matrix multiplications
		cpu_data = '0;
		gpc_val_s = 13'd16;
		gpc_val_i = 13'd28;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd6;
		repeat_op_amount = 8'd1;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#1200ns;
		
		//6 2x2 by 2x1 matrix multiplications
		cpu_data = '0;
		gpc_val_s = '0;
		gpc_val_i = 13'd36;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd5;
		repeat_op_amount = 8'd5;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#2000ns;
		
		//6 2x2 by 2x1 matrix multiplications (testing that it works consecutively)
		cpu_data = '0;
		gpc_val_s = '0;
		gpc_val_i = 13'd36;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd5;
		repeat_op_amount = 8'd5;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#2000ns;
		
		//2 4x4 by 4x1 matrix multiplications (testing return from x2 to x4 mode)
		cpu_data = '0;
		gpc_val_s = 13'd16;
		gpc_val_i = 13'd28;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd6;
		repeat_op_amount = 8'd1;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#1200ns;
		
		//LOADING MRAM FROM VRAM
		gpc_val_s = 13'd8; //NUMBER OF DUAL TRANSFERS ALREADY IN!! EACH ADDRESS TAKES 2 VALUES
		gpc_val_i = 13'd24;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd4;
		repeat_op_amount = 8'd1;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#800ns;
		
		//6 2x1 + 2x1 matrix additions
		cpu_data = 13'd8;
		gpc_val_s = '0;
		gpc_val_i = 13'd48;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd9;
		repeat_op_amount = 8'd5;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#2000ns;
		
		//LOADING VRAM FROM INT TO FP
		int_to_fp = 16'd2424;
		gpc_val_s = 13'd60;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd2;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#200ns;
		
		//SAVING TO CPU OUTPUT DATA
		gpc_val_s = 13'd34;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd10;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#200ns;
		
		//SAVING TO CPU OUTPUT DATA
		gpc_val_s = 13'd34;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd11;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#200ns;
		
		//INIT DISPLAY
		gpc_val_s = '0;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd12;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#500000ns;
		
		//SEND NEXT FRAME
		gpc_val_s = '0;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd13;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#5000000ns;
		
		//SEND NEXT FRAME (repeat to fill framebuffer with 0s again)
		gpc_val_s = '0;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd13;
		repeat_op_amount = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#7500000ns;
		
		//Drawing pix at 0,0
		instruction = 5'd1;
		gpc_val_s = 13'd61;
		cpu_data = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		#60ns;
		
		gpc_val_s = 13'd62;
		cpu_data = '0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		#60ns;
		
		gpc_val_s = 13'd59;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd8;
		repeat_op_amount = 8'd1;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#500ns;
		
		gpc_val_s = 13'd59;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd2;
		instruction = 5'd7;
		repeat_op_amount = 8'd1;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#10000ns;
		
		//OVERWRITE PIXEL BACK TO BLACK
		cpu_data = '0;
		gpc_val_s = 13'd59;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd1;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd3;
		repeat_op_amount = 8'd0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#200ns;
		
		gpc_val_s = 13'd61;
		gpc_val_i = '0;
		gpc_inc_amount_a = 8'd2;
		gpc_inc_amount_b = 8'd1;
		instruction = 5'd8;
		repeat_op_amount = 8'd0;
		gpu_start = '1;
		#20ns;
		gpu_start = '0;
		
		#500ns;
		
		$stop;
	end
endmodule