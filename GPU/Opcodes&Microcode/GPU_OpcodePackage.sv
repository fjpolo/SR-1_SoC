package GPU_OpcodePackage;

	typedef enum logic [4:0] {
		gNXI, //WORKING 16/2/25
		gLDC, //WORKING 16/2/25
		gLDI, //WORKING 16/2/25
		gSDC, //WORKING 17/2/25
		gLMV, //WORKING 16/2/25
		gMM2, //WORKING 16/2/25
		gMM4, //WORKING 16/2/25
		gDRL, //WORKING 17/2/25
		gDRP, //WORKING 17/2/25
		gMA2, //WORKING 16/2/25
		gSCO, //WORKING 16/2/25
		gSCI, //WORKING 16/2/25
		gINI, //WORKING 16/2/25
		gSNF, //WORKING 16/2/25
		gCPY  //NOT TESTED
	} GPU_Opcode_enum;

endpackage