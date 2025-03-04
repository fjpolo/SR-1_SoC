module MemoryController (output logic [15:0] address, output logic [7:0] current_ram, mm_prescale,
						inout tri [15:0] data_bus,
						input logic set_mar, read_m, write_m, read_r, write_r, clk,
						input logic set_mar_btn, set_ram_btn, programming_mode, reset, prog_clk); //Direct programming inputs
	
	logic read_mdr, write_mdr, read_ram, write_ram, set_mar_internal, mc_clk;
	
	typedef enum {
				idle,
				write_mdr_state,
				write_ram_state,
				read_ram_state
	} ControlStatus;
	
	ControlStatus current_state = idle;
	
	assign mc_clk = programming_mode ? prog_clk : clk;
	
	assign data_bus[15:8] = read_ram ? '0 : 'z; //Most significant bits of data bus pulled low permanently
	
	//Internal Hardware
	RAM #(.ADDRESS_SIZE(15)) ram (.memory_data_bus(data_bus[7:0]), .address(address[14:0]), .mem_clk(mc_clk),
								.read(read_ram), .write(write_ram), .current_ram(current_ram), .mm_prescale(mm_prescale));
	RW_Register #(.N(16)) mdr(.data_bus(data_bus), .direct_out(), .read(read_mdr), .write(write_mdr), .clk(clk), .reset(reset));
	RW_Register #(.N(16)) mar(.data_bus(data_bus), .direct_out(address), .write(set_mar_internal), .read('0), .clk(mc_clk), .reset(reset));
	
	always_comb
	begin
		read_mdr = '0;
		write_mdr = '0;
		write_ram = '0;
		read_ram = '0;
		set_mar_internal = '0;
		
		if (programming_mode)
		begin
			set_mar_internal = set_mar_btn;
			write_ram = set_ram_btn;
		end
		else
		begin
			unique case (current_state)
				idle : begin
					read_mdr = read_m;
					set_mar_internal = set_mar;
				end
				
				write_mdr_state : begin
					write_mdr = '1;
				end
				
				write_ram_state : begin //MDR -> RAM
					read_mdr = '1;
					write_ram = '1;
				end
				
				read_ram_state : begin //RAM -> MDR
					write_mdr = '1;
					read_ram = '1;
				end
				
				default : begin //ERROR STATE
					read_mdr = '0;
					write_mdr = '0;
					write_ram = '0;
					read_ram = '0;
					set_mar_internal = '0;
				end
			endcase
		end
	end
		
	always_comb
		if (write_m) current_state = write_mdr_state;
		else if (read_r) current_state = read_ram_state;
		else if (write_r) current_state = write_ram_state;
		else current_state = idle;
endmodule
