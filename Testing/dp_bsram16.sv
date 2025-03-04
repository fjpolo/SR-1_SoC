module DP_BSRAM16 (
        output logic [15:0] douta, doutb,
        input logic clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb,
        input logic [9:0] ada, adb,
        input logic [15:0] dina, dinb);
	
	bsram_test #(.A_SIZE(10), .DEPTH(1024), .W_SIZE(16)) bsram_t0 (
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