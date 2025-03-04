import MicrocodePackage::*;

module Microcode (output logic half_mode_override, set_flags, set_half_mode, set_full_mode,					//Misc
				rda, rdb, rdc, rdd, lda, ldb, ldc, ldd, ldi, set_alu_output,								//Regs
				alu_sub, alu_mult, alu_and, alu_or, alu_xor, alu_not, alu_bytewise, alu_lshift, alu_rshift,	//ALU
				inc_pc, dec_pc, set_pc, reset_pc, read_pc,													//PC
				dubdab_start,																				//DD
				ram_set_mar, ram_set_mtar, ram_read, ram_write, ram_dtransfer, ram_set_xfer_gpu, ram_rd_as_addr,//RAM
				ms_timer_start, us_timer_start,																//Timers
				gpu_start,																					//GPU
				hlt_gpu, hlt_dubdab, hlt_ms, hlt_us, hlt_ftu, hlt_cpu,										//HLT
				input Microcode_enum current_microcode, input logic flag_carry, flag_zero);
	
	always_comb
	begin
		half_mode_override = '0;
		set_flags = '0;
		set_half_mode = '0;
		set_full_mode = '0;
		rda = '0;
		rdb = '0;
		rdc = '0;
		rdd = '0;
		lda = '0;
		ldb = '0;
		ldc = '0;
		ldd = '0;
		ldi = '0;
		set_alu_output = '0;
		alu_sub = '0;
		alu_mult = '0;
		alu_and = '0;
		alu_or = '0;
		alu_xor = '0;
		alu_not = '0;
		alu_bytewise = '0;
		alu_lshift = '0;
		alu_rshift = '0;
		inc_pc = '0;
		dec_pc = '0;
		set_pc = '0;
		reset_pc = '0;
		read_pc = '0;
		dubdab_start = '0;
		ram_set_mar = '0;
		ram_set_mtar = '0;
		ram_read = '0;
		ram_write = '0;
		ram_dtransfer = '0;
		ram_set_xfer_gpu = '0;
		ram_rd_as_addr = '0;
		ms_timer_start = '0;
		us_timer_start = '0;
		gpu_start = '0;
		hlt_gpu = '0;
		hlt_dubdab = '0;
		hlt_ms = '0;
		hlt_us = '0;
		hlt_ftu = '0;
		hlt_cpu = '0;
		
		unique case (current_microcode)
			ENDMICRO : ; //Nothing
			
			WAIT_CYCLE : ; //Nothing
			
			RAM_to_A : begin
				ram_read = '1;
				lda = '1;
			end
			
			A_to_B : begin
				rda = '1;
				ldb = '1;
			end
			
			A_to_C : begin
				rda = '1;
				ldc = '1;
			end
			
			A_to_D : begin
				rda = '1;
				ldd = '1;
			end
			
			RAM_to_D : begin
				ram_read = '1;
				ldd = '1;
			end
			
			RAM_to_IR : begin
				ram_read = '1;
				ldi = '1;
				half_mode_override = '1;
			end
			
			A_to_RAM : begin
				rda = '1;
				ram_write = '1;
			end
			
			B_to_A : begin
				rdb = '1;
				lda = '1;
			end
			
			C_to_A : begin
				rdc = '1;
				lda = '1;
			end
			
			RAM_to_PC : begin //JMP
				ram_read = '1;
				ram_rd_as_addr = '1;
				set_pc = '1;
				half_mode_override = '1;
			end
			
			RAM_to_PC_CF : begin //JPC
				if (flag_carry)
				begin
					ram_read = '1;
					ram_rd_as_addr = '1;
					set_pc = '1;
					half_mode_override = '1;
				end
			end
			
			RAM_to_PC_ZF : begin //JPZ
				if (flag_zero)
				begin
					ram_read = '1;
					ram_rd_as_addr = '1;
					set_pc = '1;
					half_mode_override = '1;
				end
			end
			
			PC_to_RAM : begin
				read_pc = '1;
				ram_write = '1;
			end
			
			PC_to_MAR : begin
				read_pc = '1;
				ram_set_mar = '1;
			end
			
			PC_to_MAR_ADDR : begin
				read_pc = '1;
				ram_rd_as_addr = '1;
				ram_set_mar = '1;
			end
			
			RAM_to_MAR : begin
				ram_read = '1;
				ram_rd_as_addr = '1;
				ram_set_mar = '1;
			end
			
			RAM_to_MTAR : begin
				ram_read = '1;
				ram_rd_as_addr = '1;
				ram_set_mtar = '1;
			end
			
			START_BCD : begin
				dubdab_start = '1;
			end
			
			ALU_ADD	: begin
				set_alu_output = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_SUB	: begin
				set_alu_output = '1;
				alu_sub = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_MULT : begin
				set_alu_output = '1;
				alu_mult = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_AND	: begin
				set_alu_output = '1;
				alu_and = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_OR : begin
				set_alu_output = '1;
				alu_or = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_XOR : begin
				set_alu_output = '1;
				alu_xor = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_NOT	: begin
				set_alu_output = '1;
				alu_not = '1;
				set_flags = '1;
			end
			
			ALU_AND_B : begin
				set_alu_output = '1;
				alu_and = '1;
				set_flags = '1;
				ram_read = '1;
				alu_bytewise = '1;
			end
			
			ALU_OR_B : begin
				set_alu_output = '1;
				alu_or = '1;
				set_flags = '1;
				ram_read = '1;
				alu_bytewise = '1;
			end
			
			ALU_XOR_B : begin
				set_alu_output = '1;
				alu_xor = '1;
				set_flags = '1;
				ram_read = '1;
				alu_bytewise = '1;
			end
			
			ALU_NOT_B : begin
				set_alu_output = '1;
				alu_not = '1;
				set_flags = '1;
				alu_bytewise = '1;
			end
			
			ALU_LSHIFT : begin
				set_alu_output = '1;
				alu_lshift = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			ALU_RSHIFT : begin
				set_alu_output = '1;
				alu_rshift = '1;
				set_flags = '1;
				ram_read = '1;
			end
			
			HLT_CLK	: begin
				hlt_cpu = '1;
			end
			
			INC_PC : begin
				inc_pc = '1;
			end
			
			SET_HALF : begin
				set_half_mode = '1;
			end
			
			SET_FULL : begin
				set_full_mode = '1;
			end
			
			DATA_XFER : begin
				ram_dtransfer = '1;
				half_mode_override = '1;
			end
			
			SET_MTAR_GPU : begin
				ram_set_xfer_gpu = '1;
			end
			
			START_MT : begin
				ms_timer_start = '1;
			end
			
			START_UT : begin
				us_timer_start = '1;
			end
			
			WAIT_MT : begin
				hlt_ms = '1;
			end
			
			WAIT_UT : begin
				hlt_us = '1;
			end
			
			WAIT_FT : begin
				hlt_ftu = '1;
			end
			
			WAIT_DD : begin
				hlt_dubdab = '1;
			end
			
			WAIT_GPU : begin
				hlt_gpu = '1;
			end
			
			START_GPU : begin
				gpu_start = '1;
			end
		endcase
	end
endmodule