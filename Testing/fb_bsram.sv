module DP_BSRAM (
        output logic [7:0] douta, doutb,
        input logic clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb,
        input logic [10:0] ada, adb,
        input logic [7:0] dina, dinb);
	
	bsram_test #(.A_SIZE(11), .DEPTH(2048), .W_SIZE(8)) bsram_t0 (
		.doutb(doutb), 
		.douta(douta),
		.addra(ada), 
		.addrb(adb),
		.dina(dina), 
		.dinb(dinb),
		.clk(clka),
		.reset(reseta),
		.wra(wrea), 
		.wrb(wreb), 
		.cea(cea),
		.ceb(ceb)
	);
	
endmodule