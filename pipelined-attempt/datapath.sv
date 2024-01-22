module datapath(sximm5_ex, sximm8_ex, Rm_ex, Rn_ex, mem_data, wb_data, sh_op, ALU_op, asel, bsel, imm_sel, fwd_A, fwd_B, status, ALU_out);

	//defining I/Os
	input [15:0] sximm5_ex, sximm8_ex, Rm_ex, Rn_ex, mem_data, wb_data;
	input [1:0] sh_op, ALU_op;
	input asel, bsel, imm_sel;
	input [2:0] fwd_A, fwd_B;
	output [15:0] ALU_out;
	output [2:0] status;
	
	reg [15:0] Rm_ex, a_in, b_in, a_fwd, b_fwd, b_fwd_imm;
	wire [15:0] b_data;
	reg [2:0] status;
	
	//module instantiations
	ALU U1(a_fwd, b_fwd_imm,ALU_op,ALU_out,status);
	shifter U2(Rm_ex,sh_op,b_data);
	
	
	always_comb begin 
	
		b_in = bsel ? sximm5_ex : b_data;
		a_in = asel ? 16'b0 : Rn_ex;
		a_fwd = fwd_A[2] ? wb_data : fwd_A[1] ? a_in : mem_data;
		b_fwd = fwd_B[2] ? wb_data : fwd_B[1] ? b_in : mem_data;
		b_fwd_imm = imm_sel ? sximm8_ex : b_fwd;
		
	end
	
endmodule 