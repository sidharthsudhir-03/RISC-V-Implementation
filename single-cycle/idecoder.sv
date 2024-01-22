module idecoder(instruction, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, opcode, op, cond);

	//Initializing I/Os 
	input[15:0] instruction;
	input[2:0] nsel;
	output[15:0] sximm5, sximm8;
	output[1:0] ALUop, shift, op;
	output[2:0] writenum, opcode, cond;
	wire[2:0] Rn, Rd, Rm;
	output reg[2:0] readnum;
	
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
	
	always_comb begin 
	
		//3 input mux to select between Rn, Rd, and Rm
		case(nsel)
			
			3'b001: readnum = Rn;
			3'b010: readnum = Rd;
			3'b100: readnum = Rm;
			default: readnum = 3'bxxx;
			
		endcase
		
	end
	
	assign writenum = readnum;
	assign cond = Rn;
	
	
	
endmodule 