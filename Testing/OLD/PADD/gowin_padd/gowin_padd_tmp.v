//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Thu Jan 30 22:06:26 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_PADD your_instance_name(
        .dout(dout), //output [17:0] dout
        .so(so), //output [17:0] so
        .sbo(sbo), //output [17:0] sbo
        .b(b), //input [17:0] b
        .si(si), //input [17:0] si
        .ce(ce), //input ce
        .clk(clk), //input clk
        .reset(reset) //input reset
    );

//--------Copy end-------------------
