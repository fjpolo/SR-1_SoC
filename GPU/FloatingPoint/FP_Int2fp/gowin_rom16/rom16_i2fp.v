//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.10.03 Education (64-bit)
//Part Number: GW1NR-LV9QN88PC6/I5
//Device: GW1NR-9
//Device Version: C
//Created Time: Wed Feb 12 16:42:38 2025

module ROM16_I2FP (dout, ad);

output [15:0] dout;
input [3:0] ad;

ROM16 rom16_inst_0 (
    .DO(dout[0]),
    .AD(ad[3:0])
);

defparam rom16_inst_0.INIT_0 = 16'h8000;

ROM16 rom16_inst_1 (
    .DO(dout[1]),
    .AD(ad[3:0])
);

defparam rom16_inst_1.INIT_0 = 16'h4000;

ROM16 rom16_inst_2 (
    .DO(dout[2]),
    .AD(ad[3:0])
);

defparam rom16_inst_2.INIT_0 = 16'h2000;

ROM16 rom16_inst_3 (
    .DO(dout[3]),
    .AD(ad[3:0])
);

defparam rom16_inst_3.INIT_0 = 16'h1000;

ROM16 rom16_inst_4 (
    .DO(dout[4]),
    .AD(ad[3:0])
);

defparam rom16_inst_4.INIT_0 = 16'h0800;

ROM16 rom16_inst_5 (
    .DO(dout[5]),
    .AD(ad[3:0])
);

defparam rom16_inst_5.INIT_0 = 16'h0400;

ROM16 rom16_inst_6 (
    .DO(dout[6]),
    .AD(ad[3:0])
);

defparam rom16_inst_6.INIT_0 = 16'h0200;

ROM16 rom16_inst_7 (
    .DO(dout[7]),
    .AD(ad[3:0])
);

defparam rom16_inst_7.INIT_0 = 16'h0100;

ROM16 rom16_inst_8 (
    .DO(dout[8]),
    .AD(ad[3:0])
);

defparam rom16_inst_8.INIT_0 = 16'h0080;

ROM16 rom16_inst_9 (
    .DO(dout[9]),
    .AD(ad[3:0])
);

defparam rom16_inst_9.INIT_0 = 16'h0040;

ROM16 rom16_inst_10 (
    .DO(dout[10]),
    .AD(ad[3:0])
);

defparam rom16_inst_10.INIT_0 = 16'h0020;

ROM16 rom16_inst_11 (
    .DO(dout[11]),
    .AD(ad[3:0])
);

defparam rom16_inst_11.INIT_0 = 16'h0010;

ROM16 rom16_inst_12 (
    .DO(dout[12]),
    .AD(ad[3:0])
);

defparam rom16_inst_12.INIT_0 = 16'h0008;

ROM16 rom16_inst_13 (
    .DO(dout[13]),
    .AD(ad[3:0])
);

defparam rom16_inst_13.INIT_0 = 16'h0004;

ROM16 rom16_inst_14 (
    .DO(dout[14]),
    .AD(ad[3:0])
);

defparam rom16_inst_14.INIT_0 = 16'h0002;

ROM16 rom16_inst_15 (
    .DO(dout[15]),
    .AD(ad[3:0])
);

defparam rom16_inst_15.INIT_0 = 16'h0001;

endmodule //ROM16_I2FP
