module MAUnit (output logic
			inout tri [15:0] data_bus_supr, data_bus_infr
			input logic clk, reset);
	
	logic [29:0] sum3;
	logic [28:0] acc, sum2;
	logic [19:0] sum0, sum1;
	logic [15:0] vram_rd0, vram_rd1;
	logic [4:0] exp0, exp1;
	logic write_db, sign0, sign1, sign2, sign3, acc_sign, set_acc, set_mults;
	
	assign data_bus_supr = write_db ? vram_rd0 : 'z;
	assign data_bus_infr = write_db ? vram_rd1 : 'z;
	
	//VRAM
	DP_BSRAM16 vram0 (
        .douta(vram_rd0), //output [15:0] douta
        .doutb(vram_rd1), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea(cea), //input cea TODO
        .reseta(reset), //input reseta
        .wrea(wrea), //input wrea TODO
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb(ceb), //input ceb TODO
        .resetb(reset), //input resetb
        .wreb(wreb), //input wreb TODO
        .ada(ada), //input [9:0] ada TODO
        .dina(dina), //input [15:0] dina TODO
        .adb(adb), //input [9:0] adb TODO
        .dinb(dinb) //input [15:0] dinb TODO
    );
	
	//Multipliers
	MAU_Multiplier mMult0 (.sum(sum0),
					.exp_max(exp0),
					.sign(sign0),
					.x_in(data_bus_supr), .y_in(vram_rd0),
					.set(set_mults), .clk(clk), .reset(reset));
					
	MAU_Multiplier mMult1 (.sum(sum1),
					.exp_max(exp1),
					.sign(sign1),
					.x_in(data_bus_infr), .y_in(vram_rd1),
					.set(set_mults), .clk(clk), .reset(reset));
	
	//Adders
	MAU_Adder #(.N(20)) mAdd0 (.c(sum2), .c_sign(sign2),
							.a(sum0), .b(sum1),
							.a_sign(sign0), .b_sign(sign1));
				
	MAU_Adder #(.N(20)) mAdd1 (.c(sum3), .c_sign(sign3),
							.a(sum2), .b(acc),
							.a_sign(sign2), .b_sign(acc_sign));
				
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			acc <= '0;
			acc_sign <= '0;
		end
		else if (clk)
			if(set_acc)
			begin
				acc <= sum2;
				acc_sign <= sign2;
			end
	end
endmodule