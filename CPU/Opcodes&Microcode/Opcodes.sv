import OpcodePackage::*;
import MicrocodePackage::*;

module Opcodes (output Microcode_enum ucode, 
			input Opcode_enum operation, input logic [5:0] cycle);

	always_comb
	begin
		ucode = ENDMICRO;
		unique case (operation)
			NXI : unique case (cycle) //Next instruction
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_IR;
					default : ucode = ENDMICRO;
				endcase
				
			LDA : unique case (cycle) //Load A 
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = RAM_to_A;				
					default : ucode = ENDMICRO;
				endcase
				
			LDAI : unique case (cycle) //Load A Immediate
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_A;	
					default : ucode = ENDMICRO;
				endcase
				
			RDA : unique case (cycle) //Read A to address
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = A_to_RAM;	
					default : ucode = ENDMICRO;
				endcase
				
			ATB : unique case (cycle) //Load B from A
					6'd0 : ucode = A_to_B;	
					default : ucode = ENDMICRO;
				endcase
				
			ATC : unique case (cycle) //Load C from A
					6'd0 : ucode = A_to_C;
					default : ucode = ENDMICRO;
				endcase
				
			ATD : unique case (cycle) //Load D from A
					6'd0 : ucode = A_to_D;	
					default : ucode = ENDMICRO;
				endcase
				
			LDD : unique case (cycle) //Load D
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = RAM_to_D;	
					default : ucode = ENDMICRO;
				endcase
				
			LDDI : unique case (cycle) //Load D Immediate
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_D;	
					default : ucode = ENDMICRO;
				endcase
				
			BTA : unique case (cycle) //Load A from B
					6'd0 : ucode = B_to_A;
					default : ucode = ENDMICRO;
				endcase
				
			CTA : unique case (cycle) //Load A from C
					6'd0 : ucode = C_to_A;
					default : ucode = ENDMICRO;
				endcase
				
			ADD : unique case (cycle)  //A + V@I (V@I is the data stored at the immediate address)
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_ADD;
					default : ucode = ENDMICRO;
				endcase
			
			SUB : unique case (cycle)  //A - V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_SUB;
					default : ucode = ENDMICRO;
				endcase
				
			MUL : unique case (cycle)  //A * V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_MULT;
					default : ucode = ENDMICRO;
				endcase
				
			LSHFT : unique case (cycle)  //A << 1
					6'd0 : ucode = ALU_LSHIFT;
					default : ucode = ENDMICRO;
				endcase
				
			RSHFT : unique case (cycle)  //A >> 1
					6'd0 : ucode = ALU_RSHIFT;
					default : ucode = ENDMICRO;
				endcase
				
			AND : unique case (cycle)  //A & V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_AND;
					default : ucode = ENDMICRO;
				endcase
				
			OR : unique case (cycle)  //A | V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_OR;
					default : ucode = ENDMICRO;
				endcase
				
			XOR : unique case (cycle)  //A ^ V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_XOR;
					default : ucode = ENDMICRO;
				endcase
				
			NOT : unique case (cycle)  //~A
					6'd0 : ucode = ALU_NOT;
					default : ucode = ENDMICRO;
				endcase
				
			ADDI : unique case (cycle)  //A + I (Immediate value)
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_ADD;
					default : ucode = ENDMICRO;
				endcase
			
			SUBI : unique case (cycle)  //A - I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_SUB;
					default : ucode = ENDMICRO;
				endcase
				
			MULI : unique case (cycle)  //A * I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_MULT;
					default : ucode = ENDMICRO;
				endcase
				
			ANDI : unique case (cycle)  //A & I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_AND;
					default : ucode = ENDMICRO;
				endcase
				
			ORI : unique case (cycle)  //A | I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_OR;
					default : ucode = ENDMICRO;
				endcase
				
			XORI : unique case (cycle)  //A ^ I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_XOR;
					default : ucode = ENDMICRO;
				endcase
				
			ANDB : unique case (cycle)  //A && V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_AND_B;
					default : ucode = ENDMICRO;
				endcase
				
			ORB : unique case (cycle)  //A || V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_OR_B;
					default : ucode = ENDMICRO;
				endcase
				
			XORB : unique case (cycle)  //A ^^ V@I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_MAR;
					6'd4 : ucode = WAIT_CYCLE;
					6'd5 : ucode = ALU_XOR_B;
					default : ucode = ENDMICRO;
				endcase
				
			NOTB : unique case (cycle)  //!A
					6'd0 : ucode = ALU_NOT_B;
					default : ucode = ENDMICRO;
				endcase
				
			ANDBI : unique case (cycle)  //A && I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_AND_B;
					default : ucode = ENDMICRO;
				endcase
				
			ORBI : unique case (cycle)  //A || I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_OR_B;
					default : ucode = ENDMICRO;
				endcase
				
			XORBI : unique case (cycle)  //A ^^ I
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = ALU_XOR_B;
					default : ucode = ENDMICRO;
				endcase	
			
			JMP : unique case (cycle) //JMP n : Jumps to line n + 1
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC;
					default : ucode = ENDMICRO;
				endcase
				
			JPZ : unique case (cycle) //Jump if ALU zero flag set
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC_ZF;
					default : ucode = ENDMICRO;
				endcase
				
			JPC : unique case (cycle) //Jump if ALU carry flag set
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC_CF;
					default : ucode = ENDMICRO;
				endcase
				
			BCD : unique case (cycle) //Transform value into BCD
					6'd0 : ucode = WAIT_DD;
					6'd1 : ucode = START_BCD;
					default : ucode = ENDMICRO;
				endcase
			
			CPY : unique case (cycle) //TO addr1 FROM addr2
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = INC_PC;
					6'd3 : ucode = RAM_to_MTAR;
					6'd4 : ucode = PC_to_MAR_ADDR;
					6'd5 : ucode = WAIT_CYCLE;
					6'd6 : ucode = RAM_to_MAR;
					6'd7 : ucode = DATA_XFER;
					default : ucode = ENDMICRO;
				endcase
				
			CPY2 : unique case (cycle) //TO addr1 FROM addr2 (2B transfer)
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = INC_PC;
					6'd3 : ucode = RAM_to_MTAR;
					6'd4 : ucode = PC_to_MAR_ADDR;
					6'd5 : ucode = WAIT_CYCLE;
					6'd6 : ucode = RAM_to_MAR;
					6'd7 : ucode = DATA_XFER;
					6'd8 : ucode = WAIT_CYCLE;
					6'd9 : ucode = DATA_XFER;
					default : ucode = ENDMICRO;
				endcase
				
			GPU : unique case (cycle) //Start GPU
					6'd0 : ucode = WAIT_GPU;
					6'd1 : ucode = START_GPU;
					default : ucode = ENDMICRO;
				endcase
				
			GDT3 : unique case (cycle) //GPU Data Transfer 3 args (1,2,2)Bytes
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = SET_MTAR_GPU;
					6'd3 : ucode = DATA_XFER;
					6'd4 : ucode = INC_PC;
					6'd5 : ucode = DATA_XFER;
					6'd6 : ucode = INC_PC;
					6'd7 : ucode = DATA_XFER;
					6'd8 : ucode = INC_PC;
					6'd9 : ucode = DATA_XFER;
					6'd10: ucode = INC_PC;
					6'd11: ucode = DATA_XFER;
					default : ucode = ENDMICRO;
				endcase
				
			GDT7 : unique case (cycle) //GPU Data Transfer 7 args (1,2,2,2,1,1,1)Bytes
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR;
					6'd2 : ucode = SET_MTAR_GPU;
					6'd3 : ucode = DATA_XFER;
					6'd4 : ucode = INC_PC;
					6'd5 : ucode = DATA_XFER;
					6'd6 : ucode = INC_PC;
					6'd7 : ucode = DATA_XFER;
					6'd8 : ucode = INC_PC;
					6'd9 : ucode = DATA_XFER;
					6'd10: ucode = INC_PC;
					6'd11: ucode = DATA_XFER;
					6'd12: ucode = INC_PC;
					6'd13: ucode = DATA_XFER;
					6'd14: ucode = INC_PC;
					6'd15: ucode = DATA_XFER;
					6'd16: ucode = INC_PC;
					6'd17: ucode = DATA_XFER;
					6'd18: ucode = INC_PC;
					6'd19: ucode = DATA_XFER;
					6'd20: ucode = INC_PC;
					6'd21: ucode = DATA_XFER;
					default : ucode = ENDMICRO;
				endcase
				
			SMT : unique case (cycle) //Start MS timer
					6'd0 : ucode = START_MT;
					default : ucode = ENDMICRO;
				endcase
				
			SUT : unique case (cycle) //Start US timer
					6'd0 : ucode = START_UT;
					default : ucode = ENDMICRO;
				endcase
				
			WMT : unique case (cycle) //Wait for MS timer
					6'd0 : ucode = WAIT_MT;
					default : ucode = ENDMICRO;
				endcase
				
			WUT : unique case (cycle) //Wait for US timer
					6'd0 : ucode = WAIT_UT;
					default : ucode = ENDMICRO;
				endcase
				
			WFT : unique case (cycle) //Wait for frame timer
					6'd0 : ucode = WAIT_FT;
					default : ucode = ENDMICRO;
				endcase
			
			WGPU : unique case (cycle) //Wait for GPU
					6'd0 : ucode = WAIT_GPU;
					default : ucode = ENDMICRO;
				endcase
				
			SHM : unique case (cycle) //Set Half Mode
					6'd0 : ucode = SET_HALF;
					default : ucode = ENDMICRO;
				endcase
				
			SFM : unique case (cycle) //Set Full Mode
					6'd0 : ucode = SET_FULL;
					default : ucode = ENDMICRO;
				endcase
				
			HLT : unique case (cycle) //Stop the CPU clock
					6'd0 : ucode = HLT_CLK;
					default : ucode = ENDMICRO;
				endcase
				
			JPG : unique case (cycle) //Jump if A reg > D reg
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC_GF;
					default : ucode = ENDMICRO;
				endcase
				
			JPL : unique case (cycle) //Jump if A reg < D reg
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC_LF;
					default : ucode = ENDMICRO;
				endcase
				
			JPE : unique case (cycle) //Jump if A reg == D reg
					6'd0 : ucode = INC_PC;
					6'd1 : ucode = PC_to_MAR_ADDR;
					6'd2 : ucode = WAIT_CYCLE;
					6'd3 : ucode = RAM_to_PC_EF;
					default : ucode = ENDMICRO;
				endcase
			
			default : ucode = ENDMICRO;
		endcase
	end
endmodule