module instruction_decode(clk, pc_if, pc1_if, instr_if, write_reg, write_data, w_en, Rm_data, Rn_data, Rd_data, Rm_ex, Rn_ex, Rd_out, pc_branch, sximm8_ex, sximm5_ex, ALU_op_ex, shift_ex, w_id, pc1_ex, halt, asel_ex, bsel_ex, imm_sel_ex, loads_ex, mem_cmd_mem, vsel_wb, b, beq, bne, blt, ble, bl, bx, blx);

	//defining inputs
	input[15:0] instr_if;
	input reg[15:0] write_data;
	input[7:0] pc_if, pc1_if;
	input[2:0] write_reg;
	input reg w_en, clk;
	
	//defining outputs
	output[15:0] Rm_data, Rn_data, Rd_data, sximm8_ex, sximm5_ex;
	output[7:0] pc1_ex, pc_branch;
	output[2:0] Rm_ex, Rn_ex, Rd_out, vsel_wb;
	output[1:0] mem_cmd_mem, ALU_op_ex, shift_ex;
	output w_id, halt, asel_ex, bsel_ex, imm_sel_ex, loads_ex, b, beq, bne, blt, ble, bl, bx, blx;
	
	//Idecoder I/O
	wire[2:0] opcode_id, cond_id, Rd_ex;
	wire[1:0] op_id;
	
	
	//Control Unit I/O
	reg[2:0] opcode_cu, cond_cu;
	reg[1:0] op_cu;
	wire return_val_id;
	
	//Regfile I/O
	reg[2:0] Rm_dec, Rn_dec, Rd_dec;

	assign pc1_ex = pc1_if;
	assign pc_branch = pc1_if + sximm8_ex[7:0];
	
	
	regfile REGFILE(clk, Rm_dec, Rn_dec, Rd_dec, write_reg, w_en, write_data, Rm_data, Rn_data, Rd_data);
	idecoder ID(instr_if, ALU_op_ex, sximm5_ex, sximm8_ex, shift_ex, Rn_ex, Rm_ex, Rd_ex, opcode_id, op_id, cond_id);
	control_unit CU(opcode_cu, op_cu, cond_cu, halt, w_id, asel_ex, bsel_ex, imm_sel_ex, loads_ex, mem_cmd_mem, vsel_wb, b, beq, bne, blt, ble, bl, bx, blx, return_val_id);
	
	assign Rd_out = return_val_id ? 3'd7: Rd_ex;
	
	always_comb begin
	
		Rm_dec = Rm_ex;
		Rn_dec = Rn_ex;
		Rd_dec = Rd_ex;
		opcode_cu = opcode_id;
		op_cu = op_id;
		cond_cu = cond_id;
		
	end
	
	
endmodule


	