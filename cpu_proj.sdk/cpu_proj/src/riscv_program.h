#ifndef PROGRAM_H
#define PROGRAM_H

// 1. addi & tH[fBO
static unsigned int ADDI_REQUIRE_FORWARD[] = {
	0b00111110100000000000000010010011,     // addi x1, x0, 1000	-> x1 = 1000
	0b00000000000000000000000000010011,     // nop
	0b01111101000000001000000100010011,     // addi x2, x1, 2000	-> x2 = 3000
	0b11000001100000010000000110010011,     // addi x3, x2, -1000   -> x3 = 2000
	0b00000000000000000000000000010011,     // nop
	0b10000011000000011000001000010011,     // addi x4, x3, -2000   -> x4 = 0
	0b00111110100000100000001010010011,     // addi x5, x4, 1000    -> x5 = 1000
	0b10000011000000101000001100010011,     // addi x6, x5, -2000   -> x6 = -1000
	0b00000000000000000000000000010011,     // nop
	0b00000000000000000000000000010011,     // nop
	0b10000011000000110000001110010011,     // addi x7, x6, -2000   -> x7 = -3000
	0b01111101000000111000010000010011,     // addi x8, x7, 2000    -> x8 = -1000
	0b01111101000001000000010010010011,     // addi x9, x8, 3000    -> x9 = 1000
	0b00000000000000000000000000010011,     // nop
	0b11110011100001001000010010010011,     // addi x9, x9, -200    -> x9 = 800
	0b11101101010001001000010010010011,     // addi x9, x9, -300    -> x9 = 500
	0b11100111000001001000010010010011,     // addi x9, x9, -400    -> x9 = 100
	0b11111100111001001000010010010011,     // addi x9, x9, -50     -> x9 = 50
	0b00000110010001001000010010010011,     // addi x9, x9, 100     -> x9 = 150
	0
};

// 2. beq
static unsigned int BEQ[] = {
	0b00000000000000000000000110010011, 	// addi x3, x0, 0
	0b00000000101000000000000010010011, 	// addi x1, x0, 10
	0b00000001010000000000000100010011, 	// addi x2, x0, 20
	0b00000000001000001000010001100011, 	// beq x1, x2, 8
	0b00000000101000011000000110010011, 	// addi x3, x3, 10
	0b00000001010000011000000110010011, 	// addi x3, x3, 20		> x3 = 30
	0b00000001010000000000000010010011, 	// addi x1, x0, 20
	0b00000000001000001000010001100011, 	// beq x1, x2, 8
	0b00000000101000011000000110010011, 	// addi x3, x3, 10
	0b00000001010000011000000110010011, 	// addi x3, x3, 20		-> x3 = 50
	0
};

// 3. VvΘZ
static unsigned int SIMPLE_CALC[] = {
	0b00000000110000000000000010010011, 	// addi x1, x0, 12		-> x1 = 12
	0b00000000010000000000000100010011, 	// addi x2, x0, 4		-> x2 = 4
	0b00000001000000000000000110010011, 	// addi x3, x0, 16		-> x3 = 16
	0b00000000001000001000001000110011, 	// add x4, x1, x2		-> x4 = 16
	0b00000000001100001000001010110011, 	// add x5, x1, x3		-> x5 = 28
	0b01000000001000001000001100110011,	 	// sub x6, x1, x2		-> x6 = 8
	0b01000000001100001000001110110011, 	// sub x7, x1, x3		-> x7 = -4
	0
};

// 4. _Z 1
static unsigned int LOGIC_CALC_1[] = {
	0b00000000111000000000000010010011, 	// addi x1, x0, 14		-> x1 = b01110
	0b00000001010000000000000100010011, 	// addi x2, x0, 20		-> x2 = b10100
	0b00000000001000001111000110110011, 	// and x3, x1, x2		-> x3 = b00100
	0b00000000001000001110001000110011, 	// or x4, x1, x2		-> x4 = b11110
	0b00000000001000001100001010110011, 	// xor x5, x1, x2		-> x5 = b11010
	0b00000001010000001111001100010011, 	// andi x6, x1, 20		-> x6 = b00100
	0b00000001010000001110001110010011, 	// ori x7, x1, 20		-> x7 = b11110
	0b00000001010000001100010000010011, 	// xori x8, x1, x2		-> x8 = b11010
	0
};

// 5. VtgZ
static unsigned int SHIFT_CALC[] = {
	0b10000000000000000000000010110111, 	// lui x1, 0x80000
	0b00000000111000001000000010010011, 	// add x1, x1, 14
	0b00000000001000000000000100010011, 	// addi x2, x0, 2
	0b00000000001000001001000110110011, 	// sll x3, x1, x2
	0b01000000001000001101001000110011, 	// sra x4, x1, x2
	0b00000000001000001101001010110011, 	// srl x5, x1, x2
	0b00000000001000001001001100010011, 	// slli x6, x1, 2
	0b01000000001000001101001110010011, 	// srai s7, x1, 2
	0b00000000001000001101010000010011, 	// srli s8, x1, 2
	0
};

// 6. _Z2
static unsigned int LOGIC_CALC_2[] = {
	0b00000000101000000000000010010011,		// addi x1, x0, 10 -> x1 = 10
	0b00000001010000000000000100010011,		// addi x2, x0, 20 -> x2 = 20
	0b00000000010100000000000110010011,		// addi x3, x0, 5  -> x3 = 5
	0b00000000001000001010001000110011,		// slt x4, x1, x2  -> x4 = 1
	0b00000000001100001010001010110011,		// slt x5, x1, x3  -> x5 = 0
	0b00000001010000001010001100010011,		// slti x6, x1, 20 -> x6 = 1
	0b00000000010100001010001110010011,		// slti x7, x1, 5  -> x7 = 0
	0
};

// 7. πͺς blt-1
static unsigned int BRANCH_BLT_1[] = {
	0b00000000101000000000000010010011, 	// addi x1, x0, 10		-> x1 = 10
	0b01000000000100000000000010110011, 	// sub x1, x0, x1		-> x1 = -10
	0b00000001010000000000000100010011, 	// addi x2, x0, 20		-> x2 = 20
	0b00000000001000001100010001100011, 	// blt x1, x2, 8
	0b00000000101000000000000110010011, 	// addi x3, x0, 10
	0b00000001010000011000000110010011, 	// add x3, x3, 20		-> x3 = 20
	0
};

// 8. πͺς blt-2
static unsigned int BRANCH_BLT_2[] = {
	0b00000000101000000000000010010011, 	// addi x1, x0, 10		-> x1 = 10
	0b01000000000100000000000010110011, 	// sub x1, x0, x1		-> x1 = -10
	0b00000001010000000000000100010011, 	// addi x2, x0, 20		-> x2 = 20
	0b00000000000100010100010001100011, 	// blt x2, x1, 8
	0b00000000101000000000000110010011, 	// addi x3, x0, 10		-> x3 = 10
	0b00000001010000011000000110010011, 	// add x3, x3, 20		-> x3 = 30
	0
};

// 9. πͺς bltu-1
static unsigned int BRANCH_BLTU_1[] = {
	0b00000000101000000000000010010011, 	// addi x1, x0, 10		-> x1 = 10
	0b01000000000100000000000010110011, 	// sub x1, x0, x1		-> x1 = -10
	0b00000001010000000000000100010011, 	// addi x2, x0, 20		-> x2 = 20
	0b00000000001000001110010001100011, 	// bltu x1, x2, 8
	0b00000000101000000000000110010011, 	// addi x3, x0, 10		-> x3 = 10
	0b00000001010000011000000110010011, 	// add x3, x3, 20		-> x3 = 30
	0
};

// 10. πͺς bltu-2
static unsigned int BRANCH_BLTU_2[] = {
	0b00000000101000000000000010010011, 	// addi x1, x0, 10		-> x1 = 10
	0b01000000000100000000000010110011, 	// sub x1, x0, x1		-> x1 = -10
	0b00000001010000000000000100010011, 	// addi x2, x0, 20		-> x2 = 20
	0b00000000000100010110010001100011, 	// bltu x2, x1, 8
	0b00000000101000000000000110010011, 	// addi x3, x0, 10
	0b00000001010000011000000110010011, 	// add x3, x3, 20		-> x3 = 20
	0
};

// 13. jalπgp΅½Wv
static unsigned int JMP_JAL[] = {
	0b00000000100000000000000011101111, 	// jal x1, 8			-> x1 = 0x2000_0004
	0b00000000101000000000000100010011, 	// addi x2, x0, 10
	0b00000001010000010000000100010011, 	// addi x2, x2, 20		-> x2 = 20
	0
};

// 14. «έ
static unsigned int WRITE_MEM[] = {
	0b00100000000000000001000010110111,		// lui x1, 0x20001
	0b00010010001101000101000100110111,		// lui x2, 0x12345
	0b01100111100000010000000100010011,		// addi x2, x2, 0x678
	0b00000000000000001010000000100011,
	0b00000000000000001010001000100011,
	0b00000000000000001010010000100011,
	0b00000000001000001000000110100011,		// sb x2, 3(x1)
	0b00000000001000001001001100100011,		// sh x2, 6(x1)
	0b00000000001000001010010000100011,		// sw x2, 8(x1)
	0
};

// 15. Lv`ρH & \¦ρH§δ
static unsigned int CAP_DISP_CONTROL[] = {
	0b00000000000000000000000010010011,		// addi x1, zero, 0
	0b10000000000000000000000010110111,		// lui x1, 0x80000
	0b00100000000000000001000100110111,		// lui x2, 0x20001
	0b00000000001000001010000000100011,		// sw x2, 0(x1)
	0b00000000000100000000000100010011,		// addi x2, zero, 1
	0b00000000001000001010001000100011,		// sw x2, 4(x1)
	0b10000000000000000001000010110111,		// lui x1, 0x80001
	0b00100000000000000001000100110111,		// lui x2, 0x20001
	0b00000000001000001010000000100011,		// sw x2, 0(x1)
	0b00000000000100000000000100010011,		// addi x2, zero, 1
	0b00000000001000001010001000100011,		// sw x2, 4(x1)
	0
};

// 16. UART
static unsigned int UART_HELLOWORLD[] = {
	0b00000000000000000000000010010011,
	0b10000000000000010000000010110111,
	0b00000001001100000000000100010011,
	0b00000000001000001010011000100011,
	0b00000100100000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110010100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110110000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110110000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110111100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000010000000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000101011100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110111100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000111001000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110110000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000110010000000000000100010011,
	0b00000000001000001010001000100011,
	0b00000010000100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000000110100000000000100010011,
	0b00000000001000001010001000100011,
	0b00000000101000000000000100010011,
	0b00000000001000001010001000100011,
	0
};

#endif
