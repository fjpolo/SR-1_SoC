import GPU_OpcodePackage::*;
import GPU_MicrocodePackage::*;

module GPU16 (output logic [15:0] gpu_data_reg, fp_to_int,
			output logic SDA_OUT, SCL, busy,
			input logic [15:0] int_to_fp, cpu_data,
			input logic [12:0] gpc_val_s, gpc_val_i,
			input logic [7:0] gpc_inc_amount_a, gpc_inc_amount_b, repeat_op_amount,
			input logic [4:0] instruction,
			input logic clk, clk_hs, reset, SDA_IN, gpu_start); //CLK_HS is highspeed 27MHz constantly
	
	//Global connections
	tri [15:0] data_bus_supr, data_bus_infr;
	logic set_gpu_ctrl_regs;
	
	assign set_gpu_ctrl_regs = gpu_start && ~busy;
	
	//Main registers
	logic [15:0] cpu_data_reg;
	logic [7:0] repeat_op_amount_reg;
	GPU_Opcode_enum next_instruction, instruction_reg;
	
	//VRAM
	logic vram_rda, vram_rdb, vram_wra, vram_wrb, vram_sada, vram_sadb, vram_sadab, vram_sadbia, vram_sadbi;
	VRAM vram0 (
		.data_bus_supr(data_bus_supr), 
		.data_bus_infr(data_bus_infr),
		.read_a(vram_rda), 
		.read_b(vram_rdb), 
		.write_a(vram_wra),
		.write_b(vram_wrb), 
		.clk(clk),
		.reset(reset),
		.set_address_a(vram_sada), 
		.set_address_b(vram_sadb),
		.set_address_a_b(vram_sadab),
		.set_address_b_a_incr(vram_sadbia),
		.set_address_b_incr(vram_sadbi)
	);
	
	//MAU4
	logic mau_all_busy, mau_any_busy, mau_start, mau_use_x2, mau_rdo, mau_smtxad, mau_wrmtx, mau_add_mode;
	MAU4 mau4_0 (
		.all_busy(mau_all_busy),
		.any_busy(mau_any_busy),
		.data_bus_supr(data_bus_supr), 
		.data_bus_infr(data_bus_infr),
		.start(mau_start),
		.use_x2_mode(mau_use_x2), 
		.clk(clk),
		.reset(reset), 
		.read_output(mau_rdo),
		.set_matrix_address(mau_smtxad), 
		.write_matrix(mau_wrmtx),
		.add_mode(mau_add_mode)
	);
	
	//Frame Buffer
	logic [9:0] fb_frame_addr;
	logic [7:0] fb_frame_data, fb_wrd_in;
	logic [6:0] fb_xc_px_ln, fb_xc_wrd;
	logic [6:0] fb_yc_px_ln;
	logic [2:0] fb_yc_wrd;
	logic fb_busy, fb_snd, fb_set_px, fb_set_col, fb_set_wrd, fb_set_px_ln, fb_pg01; 
	FrameBuffer fb0 (
		.frame_data(fb_frame_data),
		.busy(fb_busy),
		.data_bus_supr(data_bus_supr), 
		.data_bus_infr(data_bus_infr),
		.frame_address(fb_frame_addr),
		.word_in(fb_wrd_in),
		.x_coord_pix(fb_xc_px_ln),
		.x_coord_wrd(fb_xc_wrd),
		.y_coord_pix(fb_yc_px_ln[5:0]),
		.y_coord_wrd(fb_yc_wrd),
		.clk(clk_hs), 
		.send_next_data(fb_snd), 
		.reset(reset), 
		.set_pixel(fb_set_px), 
		.set_colour(fb_set_col), 
		.set_word(fb_set_wrd), 
		.set_pixel_line(fb_set_px_ln),
		.page01(fb_pg01)
	);
	
	//Display Transmission Control Unit
	logic dtcu_busy, dtcu_nack, dtcu_snd_frame, dtcu_init;
	DTCU #(.ADDRESS(8'h78)) dtcu0 (
		.data_address(fb_frame_addr),
		.SCL(SCL), 
		.busy(dtcu_busy),
		.SDA_OUT(SDA_OUT), 
		.NACK(dtcu_nack), 
		.get_next_data(fb_snd), 
		.page01(fb_pg01), 
		.frame_data(fb_frame_data),
		.init_display(dtcu_init),
		.send_frame(dtcu_snd_frame), 
		.clk(clk_hs),
		.reset(reset),
		.SDA_IN(SDA_IN)
	);
	
	//Line Drawer Unit
	logic [6:0] ldu_x0, ldu_y0;
	logic ldu_start, ldu_set_p0, ldu_busy;
	LDU #(.SIZE(7)) ldu0 (
		.xOut(fb_xc_px_ln), 
		.yOut(fb_yc_px_ln),
		.is_drawing(fb_set_px_ln),
		.x0(ldu_x0),
		.x1(data_bus_supr[6:0]), 
		.y0(ldu_y0),
		.y1(data_bus_infr[6:0]),
		.start(ldu_start),
		.clk(clk_hs),
		.reset(reset),
		.busy(ldu_busy)
	);
	
	always_ff @ (posedge clk, posedge reset)
	begin : LDU_Input_Buffer
		if (reset)
		begin
			ldu_x0 <= '0;
			ldu_y0 <= '0;
		end
		else
		begin
			if (ldu_set_p0)
			begin
				ldu_x0 <= data_bus_supr[6:0];
				ldu_y0 <= data_bus_infr[6:0];
			end
		end
	end
	
	//GPU Program Counters
	logic [7:0] gpc_inc_amount_reg[2];
	logic gpc_inc_s, gpc_inc_i, gpc_rdpc_s, gpc_rdpc_i;
	GPU_PC gpc0 (
		.bus(data_bus_supr),
		.counter_input(gpc_val_s),
		.increment_amount(gpc_inc_amount_reg[0]),
		.clk(clk), 
		.reset(reset),
		.set_pc(set_gpu_ctrl_regs),
		.inc_pc(gpc_inc_s), 
		.read_pc(gpc_rdpc_s)
	);
	
	GPU_PC gpc1 (
		.bus(data_bus_infr),
		.counter_input(gpc_val_i),
		.increment_amount(gpc_inc_amount_reg[1]),
		.clk(clk), 
		.reset(reset),
		.set_pc(set_gpu_ctrl_regs),
		.inc_pc(gpc_inc_i), 
		.read_pc(gpc_rdpc_i)
	);
	
	//CPU integer to Floating Point
	logic [15:0] cpu_i2fp_reg, i2fp_out;
	FP_Int2fp i2fp0 (
		.fp_num(i2fp_out),
		.integer_num(int_to_fp)
	);
	
	//Floating Point to CPU integer
	//2 required for the line drawer
	logic [15:0] gpu_fp2i_reg [2], gpu_fp2i [2];
	logic gpu_rd_fp2i;
	FP_FP2int fp2i0 (
		.integer_num(gpu_fp2i[0]),
		.fp_num(data_bus_supr)
	);
	
	FP_FP2int fp2i1 (
		.integer_num(gpu_fp2i[1]),
		.fp_num(data_bus_infr)
	);
	
	assign fp_to_int = gpu_fp2i_reg[0];
	assign data_bus_supr = gpu_rd_fp2i ? gpu_fp2i_reg[0] : 'z;
	assign data_bus_infr = gpu_rd_fp2i ? gpu_fp2i_reg[1] : 'z;
	
	//Control & Transfer Registers
	logic rd_cpu_data, rd_i2fp, set_output_reg, decr_rep_amount, set_fp2i_regs, set_dbi_one, bus_bridge;
	always_ff @ (posedge clk, posedge reset)
	begin : Control_Registers
		if (reset)
		begin
			//IR set within CU
			gpc_inc_amount_reg[0] <= '0;
			gpc_inc_amount_reg[1] <= '0;
			repeat_op_amount_reg <= '0;
			cpu_data_reg <= '0;
			gpu_data_reg <= '0;
			cpu_i2fp_reg <= '0;
			gpu_fp2i_reg[0] <= '0;
			gpu_fp2i_reg[1] <= '0;
		end
		else
		begin
			if (set_gpu_ctrl_regs)
			begin
				gpc_inc_amount_reg[0] <= gpc_inc_amount_a;
				gpc_inc_amount_reg[1] <= gpc_inc_amount_b;
				repeat_op_amount_reg <= repeat_op_amount;
				cpu_data_reg <= cpu_data;
				cpu_i2fp_reg <= i2fp_out;
			end
			else if (decr_rep_amount && (repeat_op_amount_reg != '0))
				repeat_op_amount_reg <= repeat_op_amount_reg - 8'd1;
			
			if (set_output_reg) gpu_data_reg <= data_bus_supr;
			
			if (set_fp2i_regs)
			begin
				gpu_fp2i_reg[0] <= gpu_fp2i[0];
				gpu_fp2i_reg[1] <= gpu_fp2i[1];
			end
		end
	end

	assign data_bus_supr = rd_cpu_data ? cpu_data_reg : 'z;
	assign data_bus_supr = rd_i2fp ? cpu_i2fp_reg : 'z;
	
	assign data_bus_infr = set_dbi_one ? 16'b0011110000000000 : 'z;
	assign data_bus_infr = bus_bridge ? data_bus_supr : 'z;
	
	//GPU conditional halt unit
	logic gpu_halt, hlt_all_mau, hlt_any_mau, hlt_fb, hlt_ldu, hlt_start, hlt_dtcu;
	always_comb
	begin : Conditional_Halt_Unit
		gpu_halt = '0;
		
		if (
			(mau_all_busy && hlt_all_mau) ||
			(mau_any_busy && hlt_any_mau) ||
			(fb_busy && hlt_fb) ||
			(ldu_busy && hlt_ldu) ||
			(~gpu_start && hlt_start) ||
			(dtcu_busy && hlt_dtcu)
		) gpu_halt = '1;
	end
	
	assign busy = ~hlt_start; //If waiting for next instruction, not busy
	
	//GPU control unit
	GPU_Microcode_enum current_microcode;
	logic [5:0] micro_addr;
	
	always_ff @ (posedge clk, posedge reset)
	begin : GPU_Control_Unit
		if (reset)
		begin
			next_instruction <= gNXI;
			instruction_reg <= gNXI;
			micro_addr <= '0;
		end
		else if (~gpu_halt)
		begin 
			if (set_gpu_ctrl_regs) 
			begin
				instruction_reg <= GPU_Opcode_enum'(instruction);
			end
			else if (current_microcode == ENDMICRO_GPU)
			begin
				micro_addr <= '0;
				
				if (instruction_reg != gNXI) instruction_reg <= gNXI;
			end
			else
			begin
				if ((current_microcode == REPEAT_UCODE) && repeat_op_amount_reg > 8'd0)
					micro_addr <= '0;
				else if ((current_microcode == CONTINUE_OR_END) && repeat_op_amount_reg == 8'd0)
					micro_addr <= '1;
				else
					micro_addr <= micro_addr + 6'd1;
			end
		end
	end
	
	//Microcode
	GPU_Microcode ucode0 (.*);
	
	//Opcodes
	GPU_Opcodes opcode0 (
		.ucode(current_microcode), 
		.operation(instruction_reg), 
		.cycle(micro_addr)
	);
	
endmodule