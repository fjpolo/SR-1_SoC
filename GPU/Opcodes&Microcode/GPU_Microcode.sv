import GPU_MicrocodePackage::*;

module GPU_Microcode (output logic vram_rda, vram_rdb, vram_wra, vram_wrb, vram_sada, vram_sadb, vram_sadab, vram_sadbia, vram_sadbi, //VRAM
				mau_start, mau_use_x2, mau_rdo, mau_smtxad, mau_wrmtx, mau_add_mode,						 			 			 //MAU
				fb_set_px, fb_set_col, fb_set_wrd,																					 //FB
				dtcu_snd_frame, dtcu_init,																							 //DTCU
				ldu_start, ldu_set_p0,																								 //LDU
				gpc_inc_s, gpc_inc_i, gpc_rdpc_s, gpc_rdpc_i,																		 //PCs
				gpu_rd_fp2i,																										 //FP2I
				rd_cpu_data, rd_i2fp, set_output_reg, decr_rep_amount, set_fp2i_regs, set_dbi_one,									 //CTRL & XFER
				hlt_all_mau, hlt_any_mau, hlt_fb, hlt_ldu, hlt_start, hlt_dtcu,														 //HALTING
				bus_bridge,																											 //Bus
				input GPU_Microcode_enum current_microcode);
	
	always_comb
	begin
		vram_rda = '0;
		vram_rdb = '0; 
		vram_wra = '0; 
		vram_wrb = '0;
		vram_sada = '0;
		vram_sadb = '0;
		vram_sadab = '0;
		vram_sadbia = '0;
		vram_sadbi = '0;
		mau_start = '0;
		mau_use_x2 = '0;
		mau_rdo = '0;
		mau_smtxad = '0; 
		mau_wrmtx = '0;
		mau_add_mode = '0;
		fb_set_px = '0;
		fb_set_col = '0;
		fb_set_wrd = '0;
		dtcu_snd_frame = '0;
		dtcu_init = '0;
		ldu_start = '0;
		ldu_set_p0 = '0;
		gpc_inc_s = '0;
		gpc_inc_i = '0;
		gpc_rdpc_s = '0;
		gpc_rdpc_i = '0;
		gpu_rd_fp2i = '0;
		rd_cpu_data = '0;
		rd_i2fp = '0;
		set_output_reg = '0;
		decr_rep_amount = '0;
		set_fp2i_regs = '0;
		set_dbi_one = '0;
		hlt_all_mau = '0;
		hlt_any_mau = '0;
		hlt_fb = '0;
		hlt_ldu = '0;
		hlt_start = '0;
		hlt_dtcu = '0;
		bus_bridge = '0;
		
		unique case (current_microcode)
			//ENDMICRO - Do nothing
			
			VRAM_to_MAU : begin //ALSO INCREMENTS PC A
				vram_rda = '1;
				vram_rdb = '1;
				gpc_inc_s = '1;
			end
			
			VRAM_to_MAU_ADD : begin //ALSO INCREMENTS PC A
				vram_rda = '1;
				set_dbi_one = '1;
				gpc_inc_s = '1;
				mau_add_mode = '1;
			end
			
			VRAM_to_MRAM : begin //ALSO INCREMENTS PC A and B
				vram_rda = '1;
				vram_rdb = '1;
				mau_wrmtx = '1;
				gpc_inc_s = '1;
				gpc_inc_i = '1;
			end
			
			MAU_to_VRAM2 : begin //ALSO INCREMENTS PC B
				mau_rdo = '1;
				vram_wra = '1;
				vram_wrb = '1;
				gpc_inc_i = '1;
				mau_use_x2 = '1;
			end 
			
			MAU_to_VRAM4 : begin //ALSO INCREMENTS PC B
				mau_rdo = '1;
				vram_wra = '1;
				vram_wrb = '1;
				gpc_inc_i = '1;
			end 
			
			INC_PC_A : begin
				gpc_inc_s = '1;
			end 
			
			INC_PC_AB : begin
				gpc_inc_s = '1;
				gpc_inc_i = '1;
			end 
			
			PC_A_to_VMAR_A : begin
				gpc_rdpc_s = '1;
				vram_sada = '1;
			end 
			
			PC_A_to_VMAR_AB : begin
				gpc_rdpc_s = '1;
				vram_sada = '1;
				vram_sadbia = '1;
			end 
			
			PC_B_to_VMAR_AB : begin
				gpc_rdpc_i = '1;
				vram_sadab = '1;
				vram_sadbi = '1;
			end 
			
			PC_AB_to_VMAR_AB : begin
				gpc_rdpc_s = '1;
				gpc_rdpc_i = '1;
				vram_sada = '1;
				vram_sadb = '1;
			end 
			
			CPU_to_VRAM : begin
				rd_cpu_data = '1;
				vram_wra = '1;
			end 
			
			CPU_FP_to_VRAM : begin
				rd_i2fp = '1;
				vram_wra = '1;
			end 
			
			SEND_FRAME : begin
				dtcu_snd_frame = '1;
			end 
			
			INIT_DISPLAY : begin
				dtcu_init = '1;
			end 
			
			WAIT_ALL_MAU : begin // These are swapped because waiting for all MAUs means none can be busy
				hlt_any_mau = '1;	 // and waiting for any MAU means at least one must be free! 
			end 
			
			WAIT_ANY_MAU : begin
				hlt_all_mau = '1;
			end 
			
			WAIT_FB : begin
				hlt_fb = '1;
			end 
			
			WAIT_LDU : begin
				hlt_ldu = '1;
			end 
			
			WAIT_START : begin
				hlt_start = '1;
			end 
			
			WAIT_DTCU : begin
				hlt_dtcu = '1;
			end 
			
			REPEAT_UCODE : begin
				decr_rep_amount = '1;
			end
			
			CONTINUE_OR_END : begin
				decr_rep_amount = '1;
			end 
			
			SET_COLOUR : begin
				rd_cpu_data = '1;
				fb_set_col = '1;
			end 
			
			VRAM_to_CPU : begin
				vram_rda = '1;
				set_output_reg = '1;
			end 
			
			VRAM_to_FP2I : begin
				vram_rda = '1;
				vram_rdb = '1;
				set_fp2i_regs = '1;
			end
			
			START_MAU4 : begin
				mau_start = '1;
			end
			
			START_MAU2 : begin
				mau_start = '1;
				mau_use_x2 = '1;
			end
			
			CPU_to_MAT_AD4 : begin
				rd_cpu_data = '1;
				mau_smtxad = '1;
			end
			
			CPU_to_MAT_AD2 : begin
				rd_cpu_data = '1;
				mau_smtxad = '1;
				mau_use_x2 = '1;
			end
			
			PC_A_to_MAT_AD4 : begin
				gpc_rdpc_s = '1;
				mau_smtxad = '1;
			end
			
			LOAD_LDU_P0 : begin //ALSO INCREMENTS PC A
				gpu_rd_fp2i = '1;
				ldu_set_p0 = '1;
				gpc_inc_s = '1;
			end
			
			START_LDU : begin //ALSO INCREMENTS PC B
				gpu_rd_fp2i = '1;
				ldu_start = '1;
				gpc_inc_i = '1;
			end
			
			DRAW_PIXEL : begin //ALSO INCREMENTS PC A
				gpu_rd_fp2i = '1;
				fb_set_px = '1;
				gpc_inc_s = '1;
			end
			
			CPY_A_to_B : begin //ALSO INCREMENTS PC A
				vram_rda = '1;
				bus_bridge = '1;
				vram_wrb = '1;
				gpc_inc_i = '1;
				gpc_inc_s = '1;
			end
			
			// WAIT_CYCLE - DOES NOTHING (JUST SKIPS ONE CLOCK CYCLE)
			default : ;
		endcase
	end
endmodule