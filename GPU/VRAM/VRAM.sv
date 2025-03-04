module VRAM (inout tri [15:0] data_bus_supr, data_bus_infr,
			input logic read_a, read_b, write_a, write_b, clk, reset, set_address_a, set_address_b, set_address_a_b, set_address_b_a_incr, set_address_b_incr);
	
	logic [15:0] data_out_a, data_out_b;
	logic [12:0] address_a, address_b;

	assign data_bus_supr = read_a ? data_out_a : 'z;
	assign data_bus_infr = read_b ? data_out_b : 'z;
	
	DP_BSRAM16V bsram16v0 (
        .douta(data_out_a), //output [15:0] douta
        .doutb(data_out_b), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea('1), //input cea
        .reseta(reset), //input reseta
        .wrea(write_a), //input wrea
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb('1), //input ceb
        .resetb(reset), //input resetb
        .wreb(write_b), //input wreb
        .ada(address_a), //input [12:0] ada
        .dina(data_bus_supr), //input [15:0] dina
        .adb(address_b), //input [12:0] adb
        .dinb(data_bus_infr) //input [15:0] dinb
    );
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			address_a <= '0;
			address_b <= '0;
		end
		else 
		begin
			if (set_address_a) address_a <= data_bus_supr [12:0];
			else if (set_address_a_b) address_a <= data_bus_infr [12:0];
			
			if (set_address_b) address_b <= data_bus_infr [12:0];
			else if (set_address_b_a_incr) address_b <= data_bus_supr [12:0] + 13'd1;
			else if (set_address_b_incr) address_b <= data_bus_infr [12:0] + 13'd1;
		end
	end
	
endmodule