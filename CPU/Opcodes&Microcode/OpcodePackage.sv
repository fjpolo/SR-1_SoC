package OpcodePackage;

	typedef enum logic [5:0] {
		NXI,    // 0x00 000000
		LDA,    // 0x01 000001
		LDAI,   // 0x02 000010
		RDA,    // 0x03 000011
		ATB,    // 0x04 000100
		ATC,    // 0x05 000101
		ATD,    // 0x06 000110
		LDD,    // 0x07 000111
		LDDI,   // 0x08 001000
		BTA,    // 0x09 001001
		CTA,    // 0x0A 001010
		ADD,    // 0x0B 001011
		SUB,    // 0x0C 001100
		MUL,    // 0x0D 001101
		LSHFT,  // 0x0E 001110
		RSHFT,  // 0x0F 001111
		AND,    // 0x10 010000
		OR,     // 0x11 010001
		XOR,    // 0x12 010010
		NOT,    // 0x13 010011
		ADDI,   // 0x14 010100
		SUBI,   // 0x15 010101
		MULI,   // 0x16 010110
		ANDI,   // 0x17 010111
		ORI,    // 0x18 011000
		XORI,   // 0x19 011001
		ANDB,   // 0x1A 011010
		ORB,    // 0x1B 011011
		XORB,   // 0x1C 011100
		NOTB,   // 0x1D 011101
		ANDBI,  // 0x1E 011110
		ORBI,   // 0x1F 011111
		XORBI,  // 0x20 100000
		JMP,    // 0x21 100001
		JPZ,    // 0x22 100010
		JPC,    // 0x23 100011
		BCD,    // 0x24 100100
		CPY,    // 0x25 100101
		CPY2,   // 0x26 100110
		GPU,    // 0x27 100111
		GDT3,   // 0x28 101000 GPU Data Transfer 3 arguments (5B)
		GDT7,   // 0x29 101001 GPU Data Transfer 7 arguments (10B)
		SMT,    // 0x2A 101010
		SUT,    // 0x2B 101011
		WMT,    // 0x2C 101100
		WUT,    // 0x2D 101101
		WFT,    // 0x2E 101110
		WGPU,   // 0x2F 101111
		SHM,    // 0x30 110000
		SFM,    // 0x31 110001
		HLT,    // 0x32 110010
		JPG,    // 0x33 110011
		JPL,    // 0x34 110100
		JPE     // 0x35 110101
	} Opcode_enum;

endpackage