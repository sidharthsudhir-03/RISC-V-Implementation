module control_unit(opcode, op, cond, halt, w_en, asel, bsel, imm_sel, loads, mem_cmd, vsel, b, beq, bne, blt, ble, bl, bx, blx, return_val);

	//Defining inputs
	input[2:0] opcode, cond;
	input[1:0] op;
	
	//Defining outputs
	output[2:0] vsel;
	output[1:0] mem_cmd;
	output halt, w_en, asel, bsel, imm_sel, loads, b, beq, bne, blt, ble, bl, bx, blx, return_val;
	
	//wire and reg
	wire[7:0] cu_in;
	reg[19:0] cu_out;
	
	assign cu_in = {opcode, op, cond};
	
	always_comb begin
	
		casex(cu_in)
		
			//MOV instructions
			8'b11010xxx: cu_out = 20'b00_001_1_0_1_x_1_0_0_0_0_0_0_0_0_0_0;
			8'b11000xxx: cu_out = 20'b00_001_1_0_1_0_0_0_0_0_0_0_0_0_0_0_0;
			
			//ALU instructions
			8'b10100xxx: cu_out = 20'b00_001_1_0_0_0_0_0_0_0_0_0_0_0_0_0_0;
			8'b10101xxx: cu_out = 20'b00_xxx_0_0_0_0_0_1_0_0_0_0_0_0_0_0_x;
			8'b10110xxx: cu_out = 20'b00_001_1_0_0_0_0_0_0_0_0_0_0_0_0_0_0;
			8'b10111xxx: cu_out = 20'b00_001_1_0_0_0_0_0_0_0_0_0_0_0_0_0_0;
			
			//LDR/STR instructions
			8'b01100xxx: cu_out = 20'b10_010_1_0_0_1_0_0_0_0_0_0_0_0_0_0_0;
			8'b10000xxx: cu_out = 20'b11_xxx_0_0_0_1_0_0_0_0_0_0_0_0_0_0_0;
			
			//Branch Instructions
			8'b00100000: cu_out = 20'b00_xxx_0_0_x_x_x_0_1_0_0_0_0_0_0_0_0;
			8'b00100001: cu_out = 20'b00_xxx_0_0_x_x_x_0_0_1_0_0_0_0_0_0_0;
			8'b00100010: cu_out = 20'b00_xxx_0_0_x_x_x_0_0_0_1_0_0_0_0_0_0;
			8'b00100011: cu_out = 20'b00_xxx_0_0_x_x_x_0_0_0_0_1_0_0_0_0_0;
			8'b00100100: cu_out = 20'b00_xxx_0_0_x_x_x_0_0_0_0_0_1_0_0_0_0;
			
			//Function Calls
			8'b01011111: cu_out = 20'b00_100_0_0_x_x_x_0_0_0_0_0_0_1_0_0_1;
			8'b01000000: cu_out = 20'b00_xxx_0_0_x_x_x_0_0_0_0_0_0_0_1_0_0;
			8'b01010111: cu_out = 20'b00_100_0_0_x_x_x_0_0_0_0_0_0_0_0_1_1;
			
			//HALT instruction
			8'b11100000: cu_out = 20'b00_xxx_0_1_x_x_x_0_0_0_0_0_0_0_0_0_x;
			
			default: cu_out = 20'bxx_xxx_x_0_x_x_x_x_x_x_x_x_x_x_x_x_x;
			
		endcase
		
	end
	
	assign {mem_cmd, vsel, w_en, halt, asel, bsel, imm_sel, loads, b, beq, bne, blt, ble, bl, bx, blx, return_val} = cu_out;
	
endmodule 
			
		
			