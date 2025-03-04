import OpcodePackage::*;
import MicrocodePackage::*;

module CPU16(output logic [5:0] n_leds, debug,
		output logic SCL, SDA_OUT,
		input logic [7:0] n_wide_sw_hi, n_wide_sw_lo, n_thin_sw,
		input logic clk_in, n_reset, SDA_IN, n_enter_btn, n_l_btn, n_r_btn, n_t_btn, n_b_btn, n_p0_btn, n_p1_btn);
	
	logic [15:0] data_bus;
	logic [7:0] buttons;
	logic reset, half_mode, half_mode_override, clk;
	//Half mode refers to using 8bit values in the ALU etc.
	
	//DEBUG OUTPUTS
	//assign debug[0] = clk;
	//assign debug[1] = half_mode;
	//assign debug[2] = '1;

	assign reset = ~n_reset; //Active low
	assign buttons = {1'd0, 
					~n_enter_btn,	//Active low
					~n_l_btn,		//Active low
					~n_r_btn,		//Active low
					~n_t_btn,		//Active low
					~n_b_btn,		//Active low
					~n_p0_btn,		//Active low
					~n_p1_btn};		//Active low

	//Registers
	logic [15:0] reg_a, reg_b, reg_c, reg_d, dbo_ra, dbo_rb, dbo_rc, dbo_rd, alu_output;
	logic [7:0] instruction_reg;
	logic rda, rdb, rdc, rdd, lda, ldb, ldc, ldd, ldi, set_alu_output, set_half_mode, set_full_mode, half_mode_reg;
	
	assign dbo_ra = rda ? reg_a : '0;
	assign dbo_rb = rdb ? reg_b : '0;
	assign dbo_rc = rdc ? reg_c : '0;
	assign dbo_rd = rdd ? reg_d : '0;
	
	always_ff @ (posedge clk , posedge reset)
	begin : CPU_Registers
		if (reset)
		begin
			reg_a <= '0;
			reg_b <= '0;
			reg_c <= '0;
			reg_d <= '0;
			instruction_reg <= '0;
			half_mode_reg <= '0;
		end
		else
		begin
			if (lda) reg_a <= data_bus;
			else if (set_alu_output) reg_a <= alu_output;
			if (ldb) reg_b <= data_bus;
			if (ldc) reg_c <= data_bus;
			if (ldd) reg_d <= data_bus;
			
			if (ldi) instruction_reg <= data_bus[7:0];
			
			if (set_half_mode) half_mode_reg <= '1;
			else if (set_full_mode) half_mode_reg <= '0;
		end
	end
	
	assign half_mode = half_mode_reg || half_mode_override;
	
	//CPU conditional jump flags
	logic set_flags, flag_carry, flag_zero, alu_zero_f, alu_carry_f;
	
	always_ff @ (posedge clk , posedge reset)
	begin : CPU_Flag_Registers
		if (reset)
		begin
			flag_carry <= '0;
			flag_zero <= '0;
		end
		else
		begin
			if (set_flags)
			begin
				flag_carry <= alu_carry_f;
				flag_zero <= alu_zero_f;
			end
		end
	end
	
	//ALU
	logic alu_sub, alu_mult, alu_and, alu_or, alu_xor, alu_not, alu_bytewise, alu_lshift, alu_rshift;
	ALU alu(
		.sum(alu_output), 
		.a(reg_a),
		.b(data_bus),
		.cout(alu_carry_f),
		.z(alu_zero_f),
		.subtract(alu_sub),
		.mult(alu_mult),
		.alu_and(alu_and),
		.alu_or(alu_or),
		.alu_xor(alu_xor),
		.alu_not(alu_not), 
		.half_mode(half_mode),
		.bytewise_mode(alu_bytewise),
		.l_shift(alu_lshift), 
		.r_shift(alu_rshift)
	);
			
	//PC
	logic [15:0] dbo_pc;
	logic inc_pc, dec_pc, set_pc, reset_pc, read_pc, ram_dual_op;
	PC pc(
		.db_out(dbo_pc),
		.data_bus(data_bus),
		.increment(inc_pc), 
		.decrement(dec_pc),
		.set(set_pc), 
		.reset_on_clk(reset_pc), 
		.clk(clk), 
		.read(read_pc), 
		.reset(reset),
		.dual_op(ram_dual_op)
	);
	
	//Double Dabbler
	logic [7:0] bcd_ascii [5];
	logic dubdab_start, dubdab_busy;
	DoubleDabbler dubdab (
		.data_bus(reg_d),
		.busy(dubdab_busy),
		.start(dubdab_start),
		.clk(clk), 
		.bcd_ascii_digits(bcd_ascii),
		.reset(reset)
	);
	
	//RAM and memory mappings
	logic [15:0] dbo_ram, gpu_fp2i, gpu_data_out, gpu_cpu_data, gpu_pca, gpu_pcb;
	logic [7:0] prescale_value, display_leds, gpu_repeat, gpu_pcai, gpu_pcbi, gpu_instr;
	logic ram_set_mar, ram_set_mtar, ram_read, ram_write, ram_dtransfer, ram_set_xfer_gpu, ram_rd_as_addr;
	RAM ram0 (
		.db_out(dbo_ram), 
		.gpu_cpu_data(gpu_cpu_data), 
		.gpu_pca(gpu_pca), 
		.gpu_pcb(gpu_pcb),
		.clk_pre(prescale_value), 
		.gpu_repeat(gpu_repeat), 
		.gpu_pcai(gpu_pcai), 
		.gpu_pcbi(gpu_pcbi), 
		.gpu_instr(gpu_instr), 
		.display_leds(display_leds),
		.dual_operation(ram_dual_op),
		.data_bus(data_bus), 
		.wide_sw({~n_wide_sw_hi, ~n_wide_sw_lo}), //Active low
		.gpu_data_out(gpu_data_out), 
		.gpu_fp2i(gpu_fp2i),
		.thin_sw(~n_thin_sw), //Active low
		.buttons(buttons), 
		.double_dabble(bcd_ascii),
		.clk(clk), 
		.reset(reset), 
		.half_mode(half_mode), 
		.read(ram_read),
		.write(ram_write), 
		.set_address(ram_set_mar),
		.set_transfer_addr(ram_set_mtar), 
		.data_transfer(ram_dtransfer),
		.set_xfer_gpu(ram_set_xfer_gpu),
		.read_as_address(ram_rd_as_addr),
		.override_dual_op(half_mode_override)
	);
	
	assign n_leds = ~display_leds[5:0];
	assign debug = instruction_reg[5:0];
	
	//Data bus
	assign data_bus = (dbo_ram | dbo_ra | dbo_rb | dbo_rc | dbo_rd | dbo_pc);
						
	//Clock Prescaler
	ClockPrescaler clkpre (.clk_hw(clk_in), .clk_out(clk), .reset(reset), .scale(prescale_value), .enable('1));
	
	//Millisecond and Microsecond Timers
	logic ms_timer_wait, us_timer_wait, ms_timer_start, us_timer_start;
	TimerMS #(.CLK_SPEED(27000000)) ms_timer (
		.waiting(ms_timer_wait),
		.repeats(reg_d),
		.start(ms_timer_start), 
		.clk(clk_in), 
		.reset(reset)
	);
	
	TimerMS #(.CLK_SPEED(27000)) us_timer (
		.waiting(us_timer_wait),
		.repeats(reg_d),
		.start(us_timer_start), 
		.clk(clk_in), 
		.reset(reset)
	);
	
	//Frame Timing Unit
	logic frame_timer_wait, n_ftw;
	FrameTimingUnit ftu0 (
		.send_frame(n_ftw),
		.clk(clk_in), 
		.reset(reset),
		.clk_pre(clk)
	);
	
	assign frame_timer_wait = ~n_ftw;
	
	//Graphics Processing Unit
	logic gpu_busy, gpu_start;
	GPU16 gpu0 (
		.gpu_data_reg(gpu_data_out), 
		.fp_to_int(gpu_fp2i),
		.SDA_OUT(SDA_OUT),
		.SCL(SCL), 
		.busy(gpu_busy),
		.int_to_fp(gpu_cpu_data), 
		.cpu_data(gpu_cpu_data),
		.gpc_val_s(gpu_pca[12:0]), 
		.gpc_val_i(gpu_pcb[12:0]),
		.gpc_inc_amount_a(gpu_pcai), 
		.gpc_inc_amount_b(gpu_pcbi), 
		.repeat_op_amount(gpu_repeat),
		.instruction(gpu_instr[4:0]),
		.clk(clk),
		.clk_hs(clk_in),
		.reset(reset), 
		.SDA_IN(SDA_IN), 
		.gpu_start(gpu_start)
	);
	
	//CPU Conditional Halting
	logic cpu_halt, hlt_cpu, hlt_gpu, hlt_dubdab, hlt_ms, hlt_us, hlt_ftu;
	
	assign cpu_halt = (hlt_cpu || 
					hlt_gpu && gpu_busy ||
					hlt_dubdab && dubdab_busy ||
					hlt_ms && ms_timer_wait ||
					hlt_us && us_timer_wait ||
					hlt_ftu && frame_timer_wait);
	
	//Microcode and Opcode decoder
	Microcode_enum current_microcode;
	Opcode_enum current_instruction;
	
	Microcode ucode (.*);
	
	logic [5:0] micro_addr;

	Opcodes opcode (
		.ucode(current_microcode), 
		.operation(current_instruction), 
		.cycle(micro_addr)
	);
	
	//DEBUG
	//assign n_leds = ~current_instruction[5:0];
	
	//Control unit
	always_ff @ (posedge clk, posedge reset)
	begin : ControlUnit
		if (reset)
		begin
			micro_addr <= '0;
			current_instruction <= NXI;
		end
		else
		begin if (~cpu_halt)	
			if (current_microcode == ENDMICRO)
			begin
				micro_addr <= '0;
				
				if (current_instruction != NXI)
					current_instruction <= NXI;
				else
					current_instruction <= Opcode_enum'(instruction_reg[5:0]);
			end
			else 
			begin
				micro_addr <= micro_addr + 6'd1;
			end
		end
	end
endmodule
