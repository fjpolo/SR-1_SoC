module DP_BSRAM ( //FOR SIM USE
        output logic [7:0] douta, //output [7:0] douta
        output logic [7:0] doutb, //output [7:0] doutb
        input logic clka, //input clka
        input logic ocea, //input ocea
        input logic cea, //input cea
        input logic reseta, //input reseta
        input logic wrea, //input wrea
        input logic clkb, //input clkb
        input logic oceb, //input oceb
        input logic ceb, //input ceb
        input logic resetb, //input resetb
        input logic wreb, //input wreb (0 is read, 1 is write)
        input logic [10:0] ada, //input [10:0] address a
        input logic [7:0] dina, //input [7:0] dina
        input logic [10:0] adb, //input [10:0] address b
        input logic [7:0] dinb //input [7:0] dinb
    );
	
	always_ff @ (posedge clka, posedge reseta)
	begin
		if (reseta)
		begin
			douta <= '0;
		end
		else if (cea)
			douta <= ada[7:0];
	end
	
	always_ff @ (posedge clkb, posedge resetb)
	begin
		if (resetb)
		begin
			doutb <= '0;
		end
		else if (ceb)
			doutb <= adb[7:0];
	end
	
endmodule