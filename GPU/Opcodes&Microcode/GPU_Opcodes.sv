import GPU_OpcodePackage::*;
import GPU_MicrocodePackage::*;

module GPU_Opcodes (output GPU_Microcode_enum ucode, 
			input GPU_Opcode_enum operation, input logic [5:0] cycle);

	always_comb
	begin
		unique case (operation)
			gNXI : unique case (cycle) //Next instruction
					6'd0 : ucode = WAIT_START;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gLDC : unique case (cycle) //Load VRAM from CPU data
					6'd0 : ucode = PC_A_to_VMAR_A;
					6'd1 : ucode = CPU_to_VRAM;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gLDI : unique case (cycle) //Load VRAM from Int2FP
					6'd0 : ucode = PC_A_to_VMAR_A;
					6'd1 : ucode = CPU_FP_to_VRAM;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gSDC : unique case (cycle) //Set draw colour
					6'd0 : ucode = WAIT_FB;
					6'd1 : ucode = SET_COLOUR;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gLMV : unique case (cycle) //Load matrix from VRAM (requires repeats equal to half matrix element count - 1)
					6'd0 : ucode = PC_B_to_VMAR_AB;
					6'd1 : ucode = PC_A_to_MAT_AD4; //A INCR = 1, B INCR = 2
					6'd2 : ucode = VRAM_to_MRAM;
					6'd3 : ucode = REPEAT_UCODE;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gMM2 : unique case (cycle) //2x2 by 2xN multiplication (repeats = N - 1)
					6'd0 : ucode = CPU_to_MAT_AD2; //NEED A,B INCREMENT OF 2
					6'd1 : ucode = PC_A_to_VMAR_AB;
					6'd2 : ucode = START_MAU2; //START 1
					6'd3 : ucode = VRAM_to_MAU;
					6'd4 : ucode = PC_A_to_VMAR_AB;
					6'd5 : ucode = START_MAU2; //START 2
					6'd6 : ucode = VRAM_to_MAU;
					6'd7 : ucode = PC_A_to_VMAR_AB;
					6'd8 : ucode = START_MAU2; //START 3
					6'd9 : ucode = VRAM_to_MAU;
					6'd10: ucode = PC_A_to_VMAR_AB;
					6'd11: ucode = START_MAU2; //START 4
					6'd12: ucode = VRAM_to_MAU;
					6'd13: ucode = PC_B_to_VMAR_AB;
					6'd14: ucode = MAU_to_VRAM2;
					6'd15: ucode = CONTINUE_OR_END; //SAVED 1
					6'd16: ucode = PC_B_to_VMAR_AB;
					6'd17: ucode = MAU_to_VRAM2;
					6'd18: ucode = CONTINUE_OR_END; //SAVED 2
					6'd19: ucode = PC_B_to_VMAR_AB;
					6'd20: ucode = MAU_to_VRAM2;
					6'd21: ucode = CONTINUE_OR_END; //SAVED 3
					6'd22: ucode = PC_B_to_VMAR_AB;
					6'd23: ucode = MAU_to_VRAM2;
					6'd24: ucode = REPEAT_UCODE; //SAVED 4
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gMM4 : unique case (cycle) //4x4 by 4xN multiplication (repeats = N - 1)
					6'd0 : ucode = CPU_to_MAT_AD4; //NEED A,B INCREMENT OF 2
					6'd1 : ucode = PC_A_to_VMAR_AB;
					6'd2 : ucode = START_MAU4;
					6'd3 : ucode = VRAM_to_MAU;
					6'd4 : ucode = PC_A_to_VMAR_AB;
					6'd5 : ucode = WAIT_CYCLE_GPU;
					6'd6 : ucode = VRAM_to_MAU;
					6'd7 : ucode = PC_B_to_VMAR_AB;
					6'd8 : ucode = WAIT_ALL_MAU;
					6'd9 : ucode = MAU_to_VRAM4;
					6'd10 : ucode = PC_B_to_VMAR_AB;
					6'd11: ucode = MAU_to_VRAM4;
					6'd12: ucode = REPEAT_UCODE;
					default : ucode = ENDMICRO_GPU;
				endcase 
				
			gDRL : unique case (cycle) //Draw line or curves (using repeats)
					6'd0 : ucode = PC_A_to_VMAR_AB;  //A INCR = 4, B INCR = 4 (for 4D, 2 for 2D)
					6'd1 : ucode = WAIT_LDU; 
					6'd2 : ucode = VRAM_to_FP2I;
					6'd3 : ucode = LOAD_LDU_P0;
					6'd4 : ucode = PC_B_to_VMAR_AB;
					6'd5 : ucode = WAIT_FB;
					6'd6 : ucode = VRAM_to_FP2I;
					6'd7 : ucode = START_LDU;
					6'd8 : ucode = REPEAT_UCODE;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gDRP : unique case (cycle) //Draw pixel or array of pixels (using repeats)
					6'd0 : ucode = PC_A_to_VMAR_AB;  //A INCR = 4 (for 4D, 2 for 2D)
					6'd1 : ucode = WAIT_FB;
					6'd2 : ucode = VRAM_to_FP2I;
					6'd3 : ucode = DRAW_PIXEL;
					6'd4 : ucode = REPEAT_UCODE;
					default : ucode = ENDMICRO_GPU;
				endcase

			gMA2 : unique case (cycle) //2x1 matrix addition via use of MAUs
					6'd0 : ucode = CPU_to_MAT_AD2; //NEED A INCREMENT OF 1, B INCREMENT OF 2
					6'd1 : ucode = PC_A_to_VMAR_AB;
					6'd2 : ucode = START_MAU2; //START 1
					6'd3 : ucode = VRAM_to_MAU_ADD;
					6'd4 : ucode = PC_A_to_VMAR_AB;
					6'd5 : ucode = WAIT_CYCLE_GPU;						//  |1|a| |x| |y| = |a+x|
					6'd6 : ucode = VRAM_to_MAU_ADD;						//	|1|b| |1| |1|   |b+y|
					6'd7 : ucode = PC_A_to_VMAR_AB;
					6'd8 : ucode = START_MAU2; //START 2
					6'd9 : ucode = VRAM_to_MAU_ADD;
					6'd10: ucode = PC_A_to_VMAR_AB;
					6'd11: ucode = WAIT_CYCLE_GPU;
					6'd12: ucode = VRAM_to_MAU_ADD;
					6'd13: ucode = PC_A_to_VMAR_AB;
					6'd14: ucode = START_MAU2; //START 3
					6'd15: ucode = VRAM_to_MAU_ADD;
					6'd16: ucode = PC_A_to_VMAR_AB;
					6'd17: ucode = WAIT_CYCLE_GPU;
					6'd18: ucode = VRAM_to_MAU_ADD;
					6'd19: ucode = PC_A_to_VMAR_AB;
					6'd20: ucode = START_MAU2; //START 4
					6'd21: ucode = VRAM_to_MAU_ADD;
					6'd22: ucode = PC_A_to_VMAR_AB;
					6'd23: ucode = WAIT_CYCLE_GPU;
					6'd24: ucode = VRAM_to_MAU_ADD;
					6'd25: ucode = PC_B_to_VMAR_AB;
					6'd26: ucode = MAU_to_VRAM2;
					6'd27: ucode = CONTINUE_OR_END; //SAVED 1
					6'd28: ucode = PC_B_to_VMAR_AB;
					6'd29: ucode = MAU_to_VRAM2;
					6'd30: ucode = CONTINUE_OR_END; //SAVED 2
					6'd31: ucode = PC_B_to_VMAR_AB;
					6'd32: ucode = MAU_to_VRAM2;
					6'd33: ucode = CONTINUE_OR_END; //SAVED 3
					6'd34: ucode = PC_B_to_VMAR_AB;
					6'd35: ucode = MAU_to_VRAM2;
					6'd36: ucode = REPEAT_UCODE; //SAVED 4
					default : ucode = ENDMICRO_GPU;
				endcase
			
			gSCO : unique case (cycle) //Set output to CPU data
					6'd0 : ucode = PC_A_to_VMAR_A;
					6'd1 : ucode = WAIT_CYCLE_GPU;
					6'd2 : ucode = VRAM_to_CPU;
					default : ucode = ENDMICRO_GPU;
				endcase
			
			gSCI : unique case (cycle) //Set output to CPU FP -> Integer
					6'd0 : ucode = PC_A_to_VMAR_A;
					6'd1 : ucode = WAIT_CYCLE_GPU;
					6'd2 : ucode = VRAM_to_FP2I;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gINI : unique case (cycle) //Initialise the display
					6'd0 : ucode = WAIT_DTCU; 
					6'd1 : ucode = INIT_DISPLAY;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gSNF : unique case (cycle) //Start sending next frame (and switch framebuffers)
					6'd0 : ucode = WAIT_DTCU;
					6'd1 : ucode = WAIT_FB;
					6'd2 : ucode = SEND_FRAME;
					default : ucode = ENDMICRO_GPU;
				endcase
				
			gCPY : unique case (cycle) //Copy value stored in A address to B address.
					6'd0 : ucode = PC_AB_to_VMAR_AB;
					6'd1 : ucode = WAIT_CYCLE_GPU; //NEED A,B INCREMENT OF > 1
					6'd2 : ucode = CPY_A_to_B;
					6'd3 : ucode = REPEAT_UCODE;
					default : ucode = ENDMICRO_GPU;
				endcase
			
			default ucode = ENDMICRO_GPU;
		endcase
	end
endmodule