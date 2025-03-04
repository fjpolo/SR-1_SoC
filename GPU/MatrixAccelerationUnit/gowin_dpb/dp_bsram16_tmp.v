//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Sat Feb  8 00:56:03 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    DP_BSRAM16 your_instance_name(
        .douta(douta), //output [15:0] douta
        .doutb(doutb), //output [15:0] doutb
        .clka(clka), //input clka
        .ocea(ocea), //input ocea
        .cea(cea), //input cea
        .reseta(reseta), //input reseta
        .wrea(wrea), //input wrea
        .clkb(clkb), //input clkb
        .oceb(oceb), //input oceb
        .ceb(ceb), //input ceb
        .resetb(resetb), //input resetb
        .wreb(wreb), //input wreb
        .ada(ada), //input [9:0] ada
        .dina(dina), //input [15:0] dina    
        .adb(adb), //input [9:0] adb
        .dinb(dinb) //input [15:0] dinb
    );

//--------Copy end-------------------
