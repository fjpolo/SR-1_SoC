module RAM (output logic [15:0] db_out, gpu_cpu_data, gpu_pca, gpu_pcb,
		output logic [7:0] clk_pre, gpu_repeat, gpu_pcai, gpu_pcbi, gpu_instr, display_leds,
		output logic dual_operation,
        inout tri [7:0] port_a_phys, port_b_phys,
		input logic [15:0] data_bus, wide_sw, gpu_data_out, gpu_fp2i, reg_a, reg_b, reg_c, reg_d,
		input logic [7:0] buttons, double_dabble [5],
		input logic clk, reset, half_mode, read, write, set_address, set_transfer_addr, data_transfer, set_xfer_gpu, read_as_address, override_dual_op);
	
	//LAST 256B of RAM is RESERVED!
	
	logic [14:0] address, transfer_addr, addr_b;
	logic [7:0] data_out_a, data_out_b, port_a_dir, port_a_data, port_b_dir, port_b_data;
	logic use_memory_map_a, use_memory_map_b, wra, wrb, rda, rdb;
	
	//Data bus connections
	logic [15:0] dbo_rega_sl, dbo_rega_sh, dbo_regbl, dbo_regbh, dbo_regcl, dbo_regch, dbo_regdl, dbo_regdh, dbo_dubdab [5], 
    dbo_wsl, dbo_wsh, dbo_btn, dbo_gfl, dbo_gfh, dbo_gdl, dbo_gdh, dbo_gin, dbo_gal, dbo_gah, dbo_gcdl, dbo_gcdh,
	dbo_gbl, dbo_gbh, dbo_gpai, dbo_gpbi, dbo_gra, dbo_ccs, dbo_douta, dbo_doutb, dbo_doutt, dbo_leds, dbo_pa_dir, dbo_pa_dat, 
    dbo_pb_dir, dbo_pb_dat;
	
	assign db_out = (dbo_dubdab[0] | dbo_dubdab[1] | dbo_dubdab[2] | dbo_dubdab[3] | dbo_dubdab[4] | dbo_leds |
	dbo_rega_sl | dbo_rega_sh | dbo_regbl | dbo_regbh | dbo_regcl | dbo_regch | dbo_regdl | dbo_regdh |
	dbo_wsl | dbo_wsh | dbo_btn | dbo_gfl | dbo_gfh | dbo_gdl | dbo_gdh | dbo_gin | dbo_gal | dbo_gah | 
	dbo_gcdl | dbo_gcdh | dbo_gbl | dbo_gbh | dbo_gpai | dbo_gpbi | dbo_gra | dbo_ccs | dbo_douta | dbo_doutb | dbo_doutt | 
    dbo_pa_dir | dbo_pa_dat | dbo_pb_dir | dbo_pb_dat);
	
	assign use_memory_map_a = (address > 15'h7EFF);
	assign use_memory_map_b = (addr_b > 15'h7EFF);
	assign wra = (write && ~data_transfer);
	assign wrb = ((write && ~half_mode) || data_transfer);
	assign rda = read || data_transfer;
	assign rdb = (read && ~half_mode) || (read && read_as_address);
	
	assign addr_b = data_transfer ? transfer_addr : (address + 15'd1);
	
	assign dbo_douta[7:0] = (rda && ~use_memory_map_a) ? data_out_a : '0;
	assign dbo_douta[15:8] = '0;
	assign dbo_doutb[7:0] = '0;
	assign dbo_doutb[15:8] = (rdb && ~use_memory_map_b) ? data_out_b : '0;
	assign dbo_doutt[7:0] = '0;
	assign dbo_doutt[15:8] = data_transfer ? data_bus[7:0] : '0;
	
	DP_BSRAM8 bsram8_0 (
        .douta(data_out_a), //output [7:0] douta
        .doutb(data_out_b), //output [7:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea('1), //input cea
        .reseta(reset), //input reseta
        .wrea(wra && ~use_memory_map_a), //input wrea
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb('1), //input ceb
        .resetb(reset), //input resetb
        .wreb(wrb && ~use_memory_map_b), //input wreb
        .ada(address), //input [14:0] ada
        .dina(data_bus[7:0]), //input [7:0] dina
        .adb(addr_b), //input [14:0] adb
        .dinb(data_bus[15:8]) //input [7:0] dinb
    );
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			address <= '0;
			transfer_addr <= '0;
			dual_operation <= '0;
		end
		else
		begin
			if (set_address)
			begin
				address <= data_bus[14:0];
				
				if (read_as_address)
					dual_operation <= '1;
				else
					dual_operation <= ~half_mode;
			end
			else if (data_transfer)
			begin
				address <= address + 15'd1;
				dual_operation <= '0;
			end
			else if (override_dual_op)
				dual_operation <= '0;
			
			if (set_transfer_addr)
				transfer_addr <= data_bus[14:0];
			else if (set_xfer_gpu)
				transfer_addr <= 15'h7FF5; //GPU DATA MEMORY START
			else if (data_transfer)
				transfer_addr <= transfer_addr + 15'd1;
		end
	end
    
    //Memory mappings
    
    //PORT A
    IO_Byte port_a (
        .physical_port(port_a_phys),
        .dir_reg(port_a_dir), 
        .logical_port(port_a_data),
        .oe('1)
    );
    
    //A CONTROL REGISTER 7FDA
    
    //Port A Logical Port (data) Register
    RW_Byte #(.ADDRESS(15'h7FDB), .RESET_VALUE(8'd0)) port_a_data_reg (
		.db_out(dbo_pa_dat),
		.data_bus(data_bus),
		.valueOutput(port_a_data),
        .valueInput(port_a_phys),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
    
    //Port A Data Direction Register
    RW_Byte #(.ADDRESS(15'h7FDC), .RESET_VALUE(8'd0)) port_a_dir_reg (
		.db_out(dbo_pa_dir),
		.data_bus(data_bus),
		.valueOutput(port_a_dir),
        .valueInput(port_a_dir),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
    
    //PORT B
    IO_Byte port_b (
        .physical_port(port_b_phys),
        .dir_reg(port_b_dir), 
        .logical_port(port_b_data),
        .oe('1)
    );
    
    //B CONTROL REGISTER 7FDD
    
    //Port B Logical Port (data) Register
    RW_Byte #(.ADDRESS(15'h7FDE), .RESET_VALUE(8'd0)) port_b_data_reg (
		.db_out(dbo_pb_dat),
		.data_bus(data_bus),
		.valueOutput(port_b_data),
        .valueInput(port_b_phys),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
    
    //Port B Data Direction Register
    RW_Byte #(.ADDRESS(15'h7FDF), .RESET_VALUE(8'd0)) port_b_dir_reg (
		.db_out(dbo_pb_dir),
		.data_bus(data_bus),
		.valueOutput(port_b_dir),
        .valueInput(port_b_dir),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//Double Dabbler (ASCII)
	RO_Byte #(.ADDRESS(15'h7FE0)) dubdab0 (
		.db_out(dbo_dubdab[0]),
		.address_a(address),
		.address_b(addr_b),
		.value(double_dabble[0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE1)) dubdab1 (
		.db_out(dbo_dubdab[1]),
		.address_a(address),
		.address_b(addr_b),
		.value(double_dabble[1]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE2)) dubdab2 (
		.db_out(dbo_dubdab[2]),
		.address_a(address),
		.address_b(addr_b),
		.value(double_dabble[2]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE3)) dubdab3 (
		.db_out(dbo_dubdab[3]),
		.address_a(address),
		.address_b(addr_b),
		.value(double_dabble[3]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE4)) dubdab4 (
		.db_out(dbo_dubdab[4]),
		.address_a(address),
		.address_b(addr_b),
		.value(double_dabble[4]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//Reg A (for splitting 2B into 2x1B)
	RO_Byte #(.ADDRESS(15'h7FE5)) reg_a_split_low (
		.db_out(dbo_rega_sl),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_a[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE6)) reg_a_split_high (
		.db_out(dbo_rega_sh),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_a[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
    //Reg B (for A to B operations)
	RO_Byte #(.ADDRESS(15'h7FE7)) reg_b_low (
		.db_out(dbo_regbl),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_b[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FE8)) reg_b_high (
		.db_out(dbo_regbh),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_b[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
    //Reg C (for A to C operations)
	RO_Byte #(.ADDRESS(15'h7FE9)) reg_c_low (
		.db_out(dbo_regcl),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_c[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FEA)) reg_c_high (
		.db_out(dbo_regch),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_c[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
    //Reg D (for A to D operations)
	RO_Byte #(.ADDRESS(15'h7FEB)) reg_d_low (
		.db_out(dbo_regdl),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_d[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FEC)) reg_d_high (
		.db_out(dbo_regdh),
		.address_a(address),
		.address_b(addr_b),
		.value(reg_d[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//Display LEDs
	RW_Byte #(.ADDRESS(15'h7FED), .RESET_VALUE(8'd0)) leds (
		.db_out(dbo_leds),
		.data_bus(data_bus),
		.valueOutput(display_leds),
        .valueInput(display_leds),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//Wide switch unit (Bottom of breadboard & 2B)
	RO_Byte #(.ADDRESS(15'h7FEE)) wide_switch_lo (
		.db_out(dbo_wsl),
		.address_a(address),
		.address_b(addr_b),
		.value(wide_sw[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FEF)) wide_switch_hi (
		.db_out(dbo_wsh),
		.address_a(address),
		.address_b(addr_b),
		.value(wide_sw[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//Buttons
	RO_Byte #(.ADDRESS(15'h7FF0)) buttons_byte (
		.db_out(dbo_btn),
		.address_a(address),
		.address_b(addr_b),
		.value(buttons),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//GPU FP2I
	RO_Byte #(.ADDRESS(15'h7FF1)) gpu_fp2i_lo (
		.db_out(dbo_gfl),
		.address_a(address),
		.address_b(addr_b),
		.value(gpu_fp2i[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FF2)) gpu_fp2i_hi (
		.db_out(dbo_gfh),
		.address_a(address),
		.address_b(addr_b),
		.value(gpu_fp2i[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//GPU -> CPU Data
	RO_Byte #(.ADDRESS(15'h7FF3)) gpu_dout_lo (
		.db_out(dbo_gdl),
		.address_a(address),
		.address_b(addr_b),
		.value(gpu_data_out[7:0]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	RO_Byte #(.ADDRESS(15'h7FF4)) gpu_dout_hi (
		.db_out(dbo_gdh),
		.address_a(address),
		.address_b(addr_b),
		.value(gpu_data_out[15:8]),
		.read_a(rda),
		.read_b(rdb),
		.clk(clk),
		.reset(reset)
	);
	
	//GPU INSTRUCTION
	RW_Byte #(.ADDRESS(15'h7FF5), .RESET_VALUE(8'd0)) gpu_instruction (
		.db_out(dbo_gin),
		.data_bus(data_bus),
		.valueOutput(gpu_instr),
        .valueInput(gpu_instr),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//GPU PC A VALUE
	RW_Byte #(.ADDRESS(15'h7FF6), .RESET_VALUE(8'd0)) gpu_pca_lo (
		.db_out(dbo_gal),
		.data_bus(data_bus),
		.valueOutput(gpu_pca[7:0]),
        .valueInput(gpu_pca[7:0]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	RW_Byte #(.ADDRESS(15'h7FF7), .RESET_VALUE(8'd0)) gpu_pca_hi (
		.db_out(dbo_gah),
		.data_bus(data_bus),
		.valueOutput(gpu_pca[15:8]),
        .valueInput(gpu_pca[15:8]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//CPU -> GPU Data
	RW_Byte #(.ADDRESS(15'h7FF8), .RESET_VALUE(8'd0)) gpu_cpu_d_lo (
		.db_out(dbo_gcdl),
		.data_bus(data_bus),
		.valueOutput(gpu_cpu_data[7:0]),
        .valueInput(gpu_cpu_data[7:0]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	RW_Byte #(.ADDRESS(15'h7FF9), .RESET_VALUE(8'd0)) gpu_cpu_d_hi (
		.db_out(dbo_gcdh),
		.data_bus(data_bus),
		.valueOutput(gpu_cpu_data[15:8]),
        .valueInput(gpu_cpu_data[15:8]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//GPU PC B VALUE
	RW_Byte #(.ADDRESS(15'h7FFA), .RESET_VALUE(8'd0)) gpu_pcb_lo (
		.db_out(dbo_gbl),
		.data_bus(data_bus),
		.valueOutput(gpu_pcb[7:0]),
        .valueInput(gpu_pcb[7:0]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	RW_Byte #(.ADDRESS(15'h7FFB), .RESET_VALUE(8'd0)) gpu_pcb_hi (
		.db_out(dbo_gbh),
		.data_bus(data_bus),
		.valueOutput(gpu_pcb[15:8]),
        .valueInput(gpu_pcb[15:8]),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//GPU PC A Increment
	RW_Byte #(.ADDRESS(15'h7FFC), .RESET_VALUE(8'd1)) gpu_pca_inc (
		.db_out(dbo_gpai),
		.data_bus(data_bus),
		.valueOutput(gpu_pcai),
        .valueInput(gpu_pcai),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//GPU PC B Increment
	RW_Byte #(.ADDRESS(15'h7FFD), .RESET_VALUE(8'd1)) gpu_pcb_inc (
		.db_out(dbo_gpbi),
		.data_bus(data_bus),
		.valueOutput(gpu_pcbi),
        .valueInput(gpu_pcbi),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//GPU Repeat Amount
	RW_Byte #(.ADDRESS(15'h7FFE), .RESET_VALUE(8'd1)) gpu_repeat_amount (
		.db_out(dbo_gra),
		.data_bus(data_bus),
		.valueOutput(gpu_repeat),
        .valueInput(gpu_repeat),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
	
	//CPU / GPU Clock Prescaler
	RW_Byte #(.ADDRESS(15'h7FFF), .RESET_VALUE(8'd7)) cpu_clock_scale (
		.db_out(dbo_ccs),
		.data_bus(data_bus),
		.valueOutput(clk_pre),
        .valueInput(clk_pre),
		.address_a(address),
		.address_b(addr_b),
		.clk(clk), 
		.reset(reset), 
		.write_a(wra), 
		.write_b(wrb), 
		.read_a(rda), 
		.read_b(rdb)
	);
endmodule

module RW_Byte #(parameter ADDRESS, RESET_VALUE) (output logic [15:0] db_out,
												output logic [7:0] valueOutput,
												input logic [15:0] data_bus,
												input logic [14:0] address_a, address_b,
                                                input logic [7:0] valueInput,
												input logic clk, reset, write_a, write_b, read_a, read_b);
	
    logic selected_a, selected_b;
	
	assign selected_a = address_a == ADDRESS;
	assign selected_b = address_b == ADDRESS;
	assign db_out[7:0] = (read_a && selected_a) ? valueInput : '0;
	assign db_out[15:8] = (read_b && selected_b) ? valueInput : '0;
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
			valueOutput <= RESET_VALUE;
		else
		begin
			if (write_a && selected_a) valueOutput <= data_bus[7:0];
			else if (write_b && selected_b) valueOutput <= data_bus[15:8];
		end
	end						
	
endmodule

module RO_Byte #(parameter ADDRESS) (output logic [15:0] db_out,
									input logic [14:0] address_a, address_b,
									input logic [7:0] value,
									input logic read_a, read_b, clk, reset);
	
	logic [7:0] value_reg;
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
			value_reg <= '0;
		else
		begin
			value_reg <= value;
		end
	end	
	
	assign db_out[7:0] = (read_a && (address_a == ADDRESS)) ? value_reg : '0;
	assign db_out[15:8] = (read_b && (address_b == ADDRESS)) ? value_reg : '0;						
endmodule

module IO_Byte (inout tri [7:0] physical_port,
                input logic [7:0] dir_reg, logical_port,
                input logic oe);
    
    assign physical_port[0] = (oe && ~dir_reg[0]) ? logical_port[0] : 'z; //Direction register == 1, input
    assign physical_port[1] = (oe && ~dir_reg[1]) ? logical_port[1] : 'z; //Direction register == 0, output
    assign physical_port[2] = (oe && ~dir_reg[2]) ? logical_port[2] : 'z;
    assign physical_port[3] = (oe && ~dir_reg[3]) ? logical_port[3] : 'z;
    assign physical_port[4] = (oe && ~dir_reg[4]) ? logical_port[4] : 'z;
    assign physical_port[5] = (oe && ~dir_reg[5]) ? logical_port[5] : 'z;
    assign physical_port[6] = (oe && ~dir_reg[6]) ? logical_port[6] : 'z;
    assign physical_port[7] = (oe && ~dir_reg[7]) ? logical_port[7] : 'z;
    
endmodule