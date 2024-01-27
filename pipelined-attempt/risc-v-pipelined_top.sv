module lab7bonus_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

	//initializing I/Os
	input[3:0]KEY; 
	input[9:0]SW;
	input CLOCK_50;
	output[9:0]LEDR; 
	output[6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	
	//Instruction Fetch I/Os
	reg load_pc_if;
	reg [3:0] branch_sel_if;
	reg [7:0] pc_branch_if, pc_rd_if;
	wire [7:0] pc_if, pc1_if;
	wire [15:0] instr_if;
	
	//IF/ID I/OS
	reg load_if_if;
	reg [7:0] pc_if_1, pc1_if_1;
	reg [15:0] instr_if_1;
	wire [7:0] pc_if_2, pc1_if_2;
	wire [15:0] instr_if_2;
	
	//Instruction Decode I/Os	
	reg[15:0] instr_if_3;
	reg[15:0] write_data_id;
	reg[7:0] pc_if_3, pc1_if_3;
	reg[2:0] write_reg_id;
	reg w_en_id;
	wire[15:0] Rm_data, Rn_data, Rd_data, sximm8_ex, sximm5_ex;
	wire[7:0] pc1_if_4, pc_branch;
	wire[2:0] Rm_ex, Rn_ex, Rd_ex, vsel_wb;
	wire[1:0] mem_cmd_mem, ALU_op_ex, shift_ex;
	wire w_reg, halt_ex, asel_ex, bsel_ex, imm_sel_ex, loads_ex, b_id, beq_id, bne_id, blt_id, ble_id, bl_id, bx_id, blx_id;
	
	//Branch Control Unit I/Os
	reg b_bc, beq_bc, bne_bc, blt_bc, ble_bc, bl_bc, bx_bc, blx_bc, N_imm, V_imm, Z_imm, N_load, V_load, Z_load, halt_bc;
	wire [3:0] pc_sel_1;
	wire load_pc1, load_if1;
	
	//ID/EX I/Os
	reg w_reg_1, asel_ex_0, bsel_ex_0, imm_sel_ex_0, loads_ex_0;
	reg[1:0] mem_cmd_mem_0, ALU_op_ex_0, shift_ex_0;
	reg[2:0] Rm_ex_0, Rn_ex_0, Rd_ex_0, vsel_wb_0;
	reg[7:0] pc1_ex_1;
	reg[15:0] Rm_data_0, Rn_data_0, sximm8_ex_0, sximm5_ex_0;
	wire w_reg_2, asel_ex_1, bsel_ex_1, imm_sel_ex_1, loads_ex_1;
	wire[1:0] mem_cmd_mem_1, ALU_op_ex_1, shift_ex_1;
	wire[2:0] Rm_ex_1, Rn_ex_1, Rd_ex_1, vsel_wb_1;
	wire[7:0] pc1_ex_2;
	wire[15:0] Rm_data_1, Rn_data_1, sximm8_ex_1, sximm5_ex_1;
	
	//Datapath I/Os
	reg [15:0] sximm5_ex_2, sximm8_ex_2, Rm_ex_2, Rn_ex_2, mem_data, wb_data;
	reg [1:0] sh_op, ALU_op;
	reg asel, bsel, imm_sel, loads;
	reg [2:0] fwd_A, fwd_B;
	wire [15:0] ALU_out;
	wire [2:0]status;
	
	//load status regitser I/O
	reg [2:0] status_in;
	wire[2:0] status_out;
	
	//EX/MEM I/Os
	reg w_reg_3;
	reg[1:0] mem_cmd_mem_2;
	reg[2:0] Rd_ex_2, vsel_wb_2;
	reg[7:0] pc1_ex_3;
	reg [15:0] ALU_out_1;
	wire w_reg_4;
	wire[1:0] mem_cmd_mem_3;
	wire[2:0] Rd_ex_3, vsel_wb_3;
	wire[7:0] pc1_ex_4;
	wire [15:0] ALU_out_2;
	
	//Memory Access I/Os
	reg[15:0] ALU_data;
	reg[1:0] mem_cmd_4;
	wire[15:0] wb_dout;
	
	//MEM/WB I/Os
	reg w_reg_5;
	reg[2:0] vsel_wb_4;
	reg[2:0] Rd_ex_4;
	reg[7:0] pc1_ex_5;
	reg[15:0] wb_dout_1, ALU_data_0;
	wire w_reg_6;
	wire[2:0] vsel_wb_5;
	wire[2:0] Rd_ex_5;
	wire[7:0] pc1_ex_6;
	wire[15:0] wb_dout_2, ALU_data_1;
	
	//Hazard Unit I/Os
	reg write_reg_mem, write_reg_wb;
	reg [2:0] Rd_mem_haz, Rd_wb_haz, Rm_ex_haz, Rn_ex_haz;
   wire [2:0] Fwd_A, Fwd_B;
	
	//Writeback mux I/Os
	reg [2:0] vsel_wb_6;
	reg [15:0] wb_dout_3, ALU_data_2;
	reg[7:0] pc1_wb;
	wire[15:0] write_data_1;
	
	//Pipeline Registers I/Os
	reg [31:0]ifid_in; 
	reg [32:0] exmem_in;
	wire [31:0] ifid_out; 
	wire[32:0] exmem_out;
	reg [94:0] idex_in;
	wire [94:0] idex_out;
	reg [46:0] memwb_in;
	wire [46:0] memwb_out;
	
	assign {pc_if_2, pc1_if_2, instr_if_2} = ifid_out;
	assign {w_reg_2, asel_ex_1, bsel_ex_1, imm_sel_ex_1, loads_ex_1, mem_cmd_mem_1, vsel_wb_1, ALU_op_ex_1, shift_ex_1, Rm_ex_1, Rn_ex_1, Rd_ex_1, pc1_ex_2, Rm_data_1, Rn_data_1, sximm8_ex_1, sximm5_ex_1} = idex_out;
	assign {w_reg_4, mem_cmd_mem_3, vsel_wb_3, Rd_ex_3, pc1_ex_4, ALU_out_2} = exmem_out;
	assign {w_reg_6, vsel_wb_5, Rd_ex_5, pc1_ex_6, wb_dout_2, ALU_data_1} =  memwb_out;
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {35{1'bx}};
	assign LEDR[9] = 1'b0;
	assign LEDR[8] = halt_ex;

	
	//module instantiation
	instruction_fetch U0 (CLOCK_50, load_pc_if, branch_sel_if, pc_branch_if, pc_rd_if, pc_if, pc1_if, instr_if);
	instruction_decode U1 (CLOCK_50, pc_if_3, pc1_if_3, instr_if_3, write_reg_id, write_data_id, w_en_id, Rm_data, Rn_data, Rd_data, Rm_ex, Rn_ex, Rd_ex, pc_branch, sximm8_ex, sximm5_ex, ALU_op_ex, shift_ex, w_reg, pc1_if_4, halt_ex, asel_ex, bsel_ex, imm_sel_ex, loads_ex, mem_cmd_mem, vsel_wb, b_id, beq_id, bne_id, blt_id, ble_id, bl_id, bx_id, blx_id);
	branch_unit U2 (CLOCK_50, ~KEY[1], b_bc, beq_bc, bne_bc, blt_bc, ble_bc, bl_bc, bx_bc, blx_bc, N_imm, V_imm, Z_imm, N_load, V_load, Z_load, halt_bc, pc_sel_1, load_pc1, load_if1);
	datapath U3 (sximm5_ex_2, sximm8_ex_2, Rm_ex_2, Rn_ex_2, mem_data, wb_data, sh_op, ALU_op, asel, bsel, imm_sel, fwd_A, fwd_B, status, ALU_out);
	hazard_unit U4 (~KEY[1], write_reg_mem, write_reg_wb, Rd_mem_haz, Rd_wb_haz, Rm_ex_haz, Rn_ex_haz, Fwd_A, Fwd_B);
	memory_access U5 (CLOCK_50, ALU_data, mem_cmd_4, SW[7:0], wb_dout, LEDR[7:0]);
	writeback U6 (vsel_wb_6, wb_dout_3, ALU_data_2, pc1_wb, write_data_1);
	
	//pipeline registers instantiation
	vDFFE  #(3) NVZ(CLOCK_50, loads, status_in, status_out);
	vDFFE #(32) IFID(CLOCK_50, load_if_if, ifid_in, ifid_out);
	vDFF #(95) IDEX(CLOCK_50, idex_in, idex_out);
	vDFF #(33) EXMEM(CLOCK_50, exmem_in, exmem_out);
	vDFF #(47) MEMWB(CLOCK_50, memwb_in, memwb_out);
	
	always_comb begin
	
		halt_bc = halt_ex;
		pc_if_1 = pc_if;
		pc1_if_1 = pc1_if;
		instr_if_1 = instr_if;
		load_pc_if = load_pc1;
		load_if_if = load_if1;
		branch_sel_if = pc_sel_1;
		pc_branch_if = pc_branch;
		pc_rd_if = Rd_data[7:0];
		instr_if_3 = instr_if_2;
		write_data_id = write_data_1;
		pc_if_3 = pc_if_2;
		pc1_if_3 = pc1_if_2;
		write_reg_id = Rd_ex_5;
		w_en_id = w_reg_6;
		b_bc = b_id;
		beq_bc = beq_id;
		bne_bc = bne_id;
		blt_bc = blt_id;
		ble_bc = ble_id;
		bl_bc = bl_id;
		bx_bc = bx_id;
		blx_bc = blx_id;
		w_reg_1 = w_reg;
		asel_ex_0 = asel_ex;
		bsel_ex_0 = bsel_ex;
		imm_sel_ex_0 = imm_sel_ex;
		loads_ex_0 = loads_ex;
		mem_cmd_mem_0 = mem_cmd_mem;
		vsel_wb_0 = vsel_wb;
		ALU_op_ex_0 = ALU_op_ex;
		shift_ex_0 = shift_ex;
		Rm_ex_0 = Rm_ex;
		Rn_ex_0 = Rn_ex;
		Rd_ex_0 = Rd_ex;
		pc1_ex_1 = pc1_if_4;
		Rm_data_0 = Rm_data;
		Rn_data_0 = Rn_data;
		sximm8_ex_0 = sximm8_ex; 
		sximm5_ex_0 = sximm5_ex;
		sximm5_ex_2 = sximm5_ex_1;
		sximm8_ex_2 = sximm8_ex_1;
		Rm_ex_2 = Rm_data_1;
		Rn_ex_2 = Rn_data_1; 
		mem_data = ALU_out_2;
		wb_data = write_data_1;
		sh_op = shift_ex_1;
		ALU_op = ALU_op_ex_1;
	   asel = asel_ex_1;
		bsel = bsel_ex_1; 
		imm_sel = imm_sel_ex_1;
		loads = loads_ex_1;
		fwd_A = Fwd_A;
		fwd_B = Fwd_B;
		status_in = status;
		N_imm = status[2]; 
		V_imm = status[1];
		Z_imm = status[0];
		N_load = status_out[2];
		V_load = status_out[1];
		Z_load = status_out[0];
		w_reg_3 = w_reg_2;
	   mem_cmd_mem_2 = mem_cmd_mem_1;
		vsel_wb_2 = vsel_wb_1;
	   Rd_ex_2 = Rd_ex_1;
	   pc1_ex_3 = pc1_ex_2;
	   ALU_out_1 = ALU_out;
		ALU_data = ALU_out_2;
	   mem_cmd_4 = mem_cmd_mem_3;
		w_reg_5 = w_reg_4;
	   vsel_wb_4 = vsel_wb_3;
		Rd_ex_4 = Rd_ex_3;
	   pc1_ex_5 = pc1_ex_4;
	   wb_dout_1 = wb_dout;
		vsel_wb_6 = vsel_wb_5;
	   wb_dout_3 = wb_dout_2;
		ALU_data_2 = ALU_data_1;
		write_reg_mem = w_reg_4;
		write_reg_wb = w_reg_6;
		Rd_mem_haz = Rd_ex_3;
		Rd_wb_haz = Rd_ex_5;
		Rm_ex_haz = Rm_ex_1;
		Rn_ex_haz = Rn_ex_1;
		pc1_wb = pc1_ex_6;
		
		ifid_in = {pc_if_1, pc1_if_1, instr_if_1};
		idex_in = {w_reg_1, asel_ex_0, bsel_ex_0, imm_sel_ex_0, loads_ex_0, mem_cmd_mem_0, vsel_wb_0, ALU_op_ex_0, shift_ex_0, Rm_ex_0, Rn_ex_0, Rd_ex_0, pc1_ex_1, Rm_data_0, Rn_data_0, sximm8_ex_0, sximm5_ex_0};
		exmem_in = {w_reg_3, mem_cmd_mem_2, vsel_wb_2, Rd_ex_2, pc1_ex_3, ALU_out_1};
		memwb_in = {w_reg_5, vsel_wb_4, Rd_ex_4, pc1_ex_5, wb_dout_1, ALU_data};
	   
		
	end
							
	
endmodule 

module vDFFE(clk, en, in, out) ;
  parameter n = 1; 
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always_ff @(posedge clk)
    out <= next_out;  
endmodule

