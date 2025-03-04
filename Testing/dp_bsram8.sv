module DP_BSRAM8 (
        output logic [7:0] douta, doutb,
        input logic clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb,
        input logic [14:0] ada, adb,
        input logic [7:0] dina, dinb);
	
	bsram_test #(.A_SIZE(15), .DEPTH(32768), .W_SIZE(8)) bsram_t0 (
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