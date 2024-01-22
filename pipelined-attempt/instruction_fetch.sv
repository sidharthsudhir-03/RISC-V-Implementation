module instruction_fetch(clk, load_pc, branch_sel, pc_branch, pc_rd, pc_if, pc1_if, instr_if);

	//defining I/Os
	input clk, load_pc;
	input[3:0] branch_sel;
	input signed[7:0] pc_branch, pc_rd;
	output signed[7:0] pc_if, pc1_if;
	output[15:0] instr_if;
	
	wire[7:0] pc_addr;
	reg[7:0] pc_reg, pc_rom;
	
	vDFFE #(8) U1(clk, load_pc, pc_reg, pc_addr);
	rom U2(pc_rom, instr_if);
	
	assign pc_if = pc_addr;
	assign pc1_if = pc_addr + 8'b1;
	
	always_comb begin 
	
		pc_rom = pc_addr;
		
		case(branch_sel)
			
			4'b0001: pc_reg = 8'd0;
			4'b0010: pc_reg = pc_addr + 8'd1;
			4'b0100: pc_reg = pc_branch;
			4'b1000: pc_reg = pc_rd;
			default: pc_reg = {8{1'bx}};
			
		endcase
		
	end
	
	
	
endmodule

// n-bit D-Flip Flop module declaration 

module vDFF(clk, in, out);
	parameter n = 1;
	input clk;
	input [n-1:0] in;
	output reg [n-1:0] out;

	always_ff @ (posedge clk)
		out <= in;
endmodule

