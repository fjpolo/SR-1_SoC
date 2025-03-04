//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.10.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sun Feb  2 22:04:24 2025

module MULT18 (dout, a, b);

output [35:0] dout;
input [17:0] a;
input [17:0] b;

wire [17:0] soa_w;
wire [17:0] sob_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

MULT18X18 mult18x18_inst (
    .DOUT(dout),
    .SOA(soa_w),
    .SOB(sob_w),
    .A(a),
    .B(b),
    .ASIGN(gw_gnd),
    .BSIGN(gw_gnd),
    .SIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .SIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd}),
    .CE(gw_gnd),
    .CLK(gw_gnd),
    .RESET(gw_gnd),
    .ASEL(gw_gnd),
    .BSEL(gw_gnd)
);

defparam mult18x18_inst.AREG = 1'b0;
defparam mult18x18_inst.BREG = 1'b0;
defparam mult18x18_inst.OUT_REG = 1'b0;
defparam mult18x18_inst.PIPE_REG = 1'b0;
defparam mult18x18_inst.ASIGN_REG = 1'b0;
defparam mult18x18_inst.BSIGN_REG = 1'b0;
defparam mult18x18_inst.SOA_REG = 1'b0;
defparam mult18x18_inst.MULT_RESET_MODE = "ASYNC";

endmodule //MULT18
