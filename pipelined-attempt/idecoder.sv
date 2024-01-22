module idecoder(instruction, ALUop, sximm5, sximm8, shift, Rn, Rm, Rd, opcode, op, cond);

	//Initializing I/Os 
	input[15:0] instruction;
	output[15:0] sximm5, sximm8;
	output[1:0] ALUop, shift, op;
	output[2:0] opcode, cond;
	output[2:0] Rn, Rd, Rm;
	
	//assigning cpu operations from instruction input
	assign sximm5 = {{11{instruction[4]}}, instruction[4:0]};
	assign sximm8 = {{8{instruction[7]}}, instruction[7:0]};
	assign ALUop = instruction[12:11];
	assign shift = instruction[4:3];
	assign opcode = instruction[15:13];
	assign op = instruction[12:11];
	assign Rn = instruction[10:8];
	assign Rd = instruction[7:5];
	assign Rm = instruction[2:0];
	assign cond = Rn;
		
endmodule 