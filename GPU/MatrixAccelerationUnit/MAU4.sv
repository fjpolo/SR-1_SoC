module MAU4 (output logic all_busy, any_busy,
			inout tri [15:0] data_bus_supr, data_bus_infr,
			input logic start, use_x2_mode, clk, reset, read_output, set_matrix_address, write_matrix, add_mode);
	
	logic [15:0] matRAM [4];
	logic [9:0] matrix_address, matRAM_address [4], matRAM_address_in [4], address_from_db;
	logic [3:0] busy;
	logic [1:0] in_addr, out_addr;
	logic mode, start_mau [4], read_output_mau [4], set_address [4];
	
	enum {x2, x4} state;
	
	assign all_busy = &busy;
	assign any_busy = |busy;
	
	assign mode = (state == x2);
	assign address_from_db = data_bus_supr[8:0] << 1'd1;
	
	//MAUs
	MAU #(.PRIMARY_OUTPUT("dbs")) mau0 (
		.busy(busy[0]),
		.data_bus_supr(data_bus_supr),
		.data_bus_infr(data_bus_infr),
		.matRAM(matRAM[0]),
		.start(start_mau[0]), 
		.mode(mode), 
		.clk(clk), 
		.reset(reset), 
		.read_output(read_output_mau[0]),
		.add_mode(add_mode)
	);
	
	MAU #(.PRIMARY_OUTPUT("dbi")) mau1 (
		.busy(busy[1]),
		.data_bus_supr(data_bus_supr),
		.data_bus_infr(data_bus_infr),
		.matRAM(matRAM[1]),
		.start(start_mau[1]), 
		.mode(mode), 
		.clk(clk), 
		.reset(reset), 
		.read_output(read_output_mau[1]),
		.add_mode(add_mode)
	);
	
	MAU #(.PRIMARY_OUTPUT("dbs")) mau2 (
		.busy(busy[2]),
		.data_bus_supr(data_bus_supr),
		.data_bus_infr(data_bus_infr),
		.matRAM(matRAM[2]),
		.start(start_mau[2]), 
		.mode(mode), 
		.clk(clk), 
		.reset(reset), 
		.read_output(read_output_mau[2]),
		.add_mode(add_mode)
	);
	
	MAU #(.PRIMARY_OUTPUT("dbi")) mau3 (
		.busy(busy[3]),
		.data_bus_supr(data_bus_supr),
		.data_bus_infr(data_bus_infr),
		.matRAM(matRAM[3]),
		.start(start_mau[3]), 
		.mode(mode), 
		.clk(clk), 
		.reset(reset), 
		.read_output(read_output_mau[3]),
		.add_mode(add_mode)
	);
	
	//matRAM (matrix RAM)
	DP_BSRAM16 dpbsram0 (
        .douta(matRAM[0]), //output [15:0] douta
        .doutb(matRAM[1]), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea('1), //input cea
        .reseta(reset), //input reseta
        .wrea(write_matrix), //input wrea
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb('1), //input ceb
        .resetb(reset), //input resetb
        .wreb(write_matrix), //input wreb
        .ada(write_matrix ? (matrix_address) : matRAM_address[0]), //input [9:0] ada
        .dina(data_bus_supr), //input [15:0] dina
        .adb(write_matrix ? (matrix_address | 10'd1) : matRAM_address[1]), //input [9:0] adb
        .dinb(data_bus_infr) //input [15:0] dinb
    );
	
	DP_BSRAM16 dpbsram1 (
        .douta(matRAM[2]), //output [15:0] douta
        .doutb(matRAM[3]), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea('0), //input ocea
        .cea('1), //input cea
        .reseta(reset), //input reseta
        .wrea(write_matrix), //input wrea
        .clkb(clk), //input clkb
        .oceb('0), //input oceb
        .ceb('1), //input ceb
        .resetb(reset), //input resetb
        .wreb(write_matrix), //input wreb
        .ada(write_matrix ? (matrix_address) : matRAM_address[2]), //input [9:0] ada
        .dina(data_bus_supr), //input [15:0] dina
        .adb(write_matrix ? (matrix_address | 10'd1) : matRAM_address[3]), //input [9:0] adb
        .dinb(data_bus_infr) //input [15:0] dinb
    );
	
	MatRAM_Lane_Controller mr_lc0 (
		.address_out(matRAM_address[0]),
		.address_in(matRAM_address_in[0]),
		.clk(clk),
		.reset(reset), 
		.mau_start(start_mau[0]),
		.set_address(set_matrix_address)
	);
	
	MatRAM_Lane_Controller mr_lc1 (
		.address_out(matRAM_address[1]),
		.address_in(matRAM_address_in[1]),
		.clk(clk),
		.reset(reset), 
		.mau_start(start_mau[1]),
		.set_address(set_matrix_address)
	);
	
	MatRAM_Lane_Controller mr_lc2 (
		.address_out(matRAM_address[2]),
		.address_in(matRAM_address_in[2]),
		.clk(clk),
		.reset(reset), 
		.mau_start(start_mau[2]),
		.set_address(set_matrix_address)
	);
	
	MatRAM_Lane_Controller mr_lc3 (
		.address_out(matRAM_address[3]),
		.address_in(matRAM_address_in[3]),
		.clk(clk),
		.reset(reset), 
		.mau_start(start_mau[3]),
		.set_address(set_matrix_address)
	);
	
	always_ff @ (posedge clk, posedge reset)
	begin
		if (reset)
		begin
			state <= x4;
			in_addr <= '0;
			out_addr <= '0;
			matrix_address <= '0;
		end
		else	
		begin
			if (set_matrix_address && ~any_busy)
				matrix_address <= address_from_db;
					
			case (state)
				x2 : begin
					if (start)
					begin
						if (~use_x2_mode && ~any_busy) 
						begin
							state <= x4;
							in_addr <= '0;
						end
						else if (~all_busy)
							in_addr <= in_addr + 2'd1;
						
						out_addr <= '0;
					end
					else if (read_output)
						out_addr <= out_addr + 2'd1;
				end
				
				x4 : begin
					if (start && ~any_busy) 
					begin
						if (use_x2_mode) 
						begin
							state <= x2;
							in_addr <= 2'd1;
							out_addr <= '0;
						end
					end
					else if (read_output)
						out_addr <= out_addr + 2'd1;
				end
			endcase
		end
	end
	
	always_comb
	begin
		if (use_x2_mode)
		begin
			start_mau[0] = start && (in_addr == 2'b00);
			start_mau[1] = start && (in_addr == 2'b01);
			start_mau[2] = start && (in_addr == 2'b10);
			start_mau[3] = start && (in_addr == 2'b11);
			
			read_output_mau[0] = read_output && (out_addr == 2'b00);
			read_output_mau[1] = read_output && (out_addr == 2'b01);
			read_output_mau[2] = read_output && (out_addr == 2'b10);
			read_output_mau[3] = read_output && (out_addr == 2'b11);
		
			matRAM_address_in[0] = address_from_db;
			matRAM_address_in[1] = address_from_db;
			matRAM_address_in[2] = address_from_db;
			matRAM_address_in[3] = address_from_db;
		end
		else 
		begin
			start_mau[0] = start;
			start_mau[1] = start;
			start_mau[2] = start;
			start_mau[3] = start;
			
			read_output_mau[0] = read_output && (~out_addr[0]);
			read_output_mau[1] = read_output && (~out_addr[0]);
			read_output_mau[2] = read_output && (out_addr[0]);
			read_output_mau[3] = read_output && (out_addr[0]);
			
			matRAM_address_in[0] = address_from_db;
			matRAM_address_in[1] = address_from_db + 10'd4;
			matRAM_address_in[2] = address_from_db + 10'd8;
			matRAM_address_in[3] = address_from_db + 10'd12;
		end
	end
endmodule