module I2C_ControllerTB;

	logic SCL, busy, NACK, SDA_TB, data_saved, sending_data, SDA_IN;
	tri SDA_OUT;
	logic start, clk, reset, send_additional_data;
	logic [7:0] address_in, data_in;
	
	I2C_Controller #(.SPEED(400)) i2c (.*);
	
	assign SDA_IN = sending_data ? SDA_OUT : SDA_TB; 
	
	initial
	begin
		start = '0;
		clk = '0;
		reset = '0;
		send_additional_data = '1;
		address_in = 8'h78;
		data_in = 8'b10100101;
		
		#1ns reset = '1;
		#1ns reset = '0;
		
		forever #37037ps clk = ~clk; //27MHz
	end
	
	initial
	begin
		#10us start = '1;
		#100ns start = '0;
	end
	
	initial //SENDING ACK and other later stuff
	begin
		#34us SDA_TB = '0; 
		#2us SDA_TB = '1;
		data_in = 8'b01011010;
		#24us send_additional_data = '0;
	end
	
endmodule
