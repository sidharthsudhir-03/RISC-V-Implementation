module controller_fsm(clk, reset, opcode, op, cond, nsel, loada, loadb, loadc, loads, asel, bsel, vsel, write, reset_pc, load_pc, load_ir, mem_cmd, addr_sel, load_addr, branch_sel, N, V, Z, halt);

	//state width
	`define SW 7
	
	//initial states
	`define RST 7'b0000000
	`define IF1 7'b0000001
	`define IF2 7'b0000010
	`define UpdatePC 7'b0000011
	
	//define different mem_cmds
	`define MREAD 2'b10
	`define MWRITE 2'b11
	`define MNONE 2'b00
	
	//reading registers Rm and Rn for different operations
	`define get_rm_mov 7'b0000100
	`define get_rm_add 7'b0000101
	`define get_rm_cmp 7'b0000110
	`define get_rm_and 7'b0000111
	`define get_rm_mvn 7'b0001000
	`define get_rn_add 7'b0001001
	`define get_rn_cmp 7'b0001010
	`define get_rn_and 7'b0001011
	
	//state operations
	`define mov_op 7'b0001100
	`define add_op 7'b0001101
	`define cmp_op 7'b0001110
	`define and_op 7'b0001111
	`define mvn_op 7'b0010000
	
	//writing to register after performing operation
	`define write_imm 7'b0010001
	`define write_rd_mov 7'b0010010
	`define write_rd_add 7'b0010011
	`define write_status 7'b0010100
	`define write_rd_and 7'b0010101
	`define write_rd_mvn 7'b0010110
	
	//ldr states
	`define get_rn_ldr 7'b0010111
	`define get_ldr_addr 7'b0011000
	`define get_data_addr_ldr 7'b0011001
	`define read_addr_ldr 7'b0011010
	`define write_rd_ldr 7'b0011011
	
	//str states
	`define get_rn_str 7'b0011100
	`define get_str_addr 7'b0011101
	`define get_data_addr_str 7'b0011110
	`define write_addr_str 7'b0011111
	`define get_rd_str 7'b0100000
	`define get_rd_out 7'b0100001
	`define write_rd_str 7'b0100010
	
	//halt operation
	`define HALT 7'b0111110
	
	//branch operations
	`define BL_0 7'b0101000
	`define BX_0 7'b0101001
	`define BLX_0 7'b0101010
	
	`define B_1 7'b0101011
	`define BEQ_1 7'b0101100
	`define BNE_1 7'b0101101
	`define BLT_1 7'b0101110
	`define BLE_1 7'b0101111
	`define BL_1 7'b0110000
	`define BX_1 7'b0110001
	`define BLX_1 7'b0110010
	
	`define BL_2 7'b0110011
	`define BX_2 7'b0110100
	
	//state machine inputs
	input clk, reset, N, V, Z;
	input[2:0] opcode, cond;
	input[1:0] op;
	
	//state machine outputs
	output loada, loadb, loadc, loads, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr;
	output reg halt;
	output[1:0] vsel, mem_cmd;
	
	output[2:0] nsel;//output that goes to the instruction decoder
	output reg[3:0] branch_sel; //selects the mux that determines next value of PC
	
	wire[7:0] fsm_in;//all inputs of fsm except reset
	reg[25:0] next;//this reg involes the next state that the machine jumps to and all the outputs of the module
	reg[`SW-1:0] next_state;
	wire[`SW-1:0] present_state, next_state_reset;//next_state_reset is the state that updates the value of next state depending on value of reset
	
	assign fsm_in = {opcode, op, cond};
	assign next_state_reset = reset ? `RST : next_state;
	vDFF #(`SW) U1(clk, next_state_reset, present_state); //a D-Flip Flop register that updates the value of present state based on the value of next_state_reset
	
	always @(*) begin
		
		//describing all state transitions
		//some instructions have fewer states than others, for instance
		//MOV_imm has 1 intermediate state
		//MOV has 2 intermediate states
		//ADD has 4 intermediate states
		//CMP has 4 intermediate states
		//AND has 4 intermediate states
		//MVN has 3 intermediate states
		//LDR has 5 intermediate states
		//STR has 7 intermediate states
		
		casex({present_state, fsm_in})
		
			//first stage for every operation; as long as present state is in the Wait state, the value of w will be 1
			//every output is set to 0, the value of nsel is set to dont care
			//when input is set to 1 then the state changes from wait
			
			{`RST, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_1_1_0_0_0, 4'b0100, 1'b0};
			{`IF1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF2, `MREAD, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_1_0, 4'b0100, 1'b0};
			{`IF2, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`UpdatePC, `MREAD, 17'b00_xxx_0_0_0_0_0_0_0_0_0_1_1_0, 4'b0100, 1'b0};
			//{`UpdatePC, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`Decode, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			
			//this is the only stage of state transitions when the inputs of the state machine matter
			
			{`UpdatePC, 8'b11010xxx}: {next, branch_sel, halt} = {`write_imm, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b11000xxx}: {next, branch_sel, halt} = {`get_rm_mov, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b10100xxx}: {next, branch_sel, halt} = {`get_rm_add, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b10101xxx}: {next, branch_sel, halt} = {`get_rm_cmp, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b10110xxx}: {next, branch_sel, halt} = {`get_rm_and, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b10111xxx}: {next, branch_sel, halt} = {`get_rm_mvn, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b01100xxx}: {next, branch_sel, halt} = {`get_rn_ldr, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b10000xxx}: {next, branch_sel, halt} = {`get_rn_str, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b11100xxx}: {next, branch_sel, halt} = {`HALT, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b00100000}: {next, branch_sel, halt} = {`B_1,`MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b00100001}: {next, branch_sel, halt} = {`BEQ_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b00100010}: {next, branch_sel, halt} = {`BNE_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b00100011}: {next, branch_sel, halt} = {`BLT_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b00100100}: {next, branch_sel, halt} = {`BLE_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b01011111}: {next, branch_sel, halt} = {`BL_0, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b01000000}: {next, branch_sel, halt} = {`BX_0, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			{`UpdatePC, 8'b01010111}: {next, branch_sel, halt} = {`BLX_0, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0100, 1'b0};
			
			//second stage of all instruction; from this stage onwards inputs do not matter
			//output is set to inputs necessary to perform operation in datapath
			{`write_imm, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b10_001_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rm_mov, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`mov_op, `MNONE, 17'b00_100_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rm_add, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_rn_add, `MNONE, 17'b00_100_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rm_cmp, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_rn_cmp, `MNONE, 17'b00_100_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rm_and, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_rn_and, `MNONE, 17'b00_100_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rm_mvn, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`mvn_op, `MNONE, 17'b00_100_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			
			//third stage of most instructions (MOV, ADD, CMP, AND, MVN)
			{`mov_op, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_mov, `MNONE, 17'b00_xxx_0_0_1_0_1_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rn_add, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`add_op, `MNONE, 17'b00_001_1_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rn_cmp, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`cmp_op, `MNONE, 17'b00_001_1_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rn_and, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`and_op, `MNONE, 17'b00_001_1_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`mvn_op, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_mvn, `MNONE, 17'b00_xxx_0_0_1_0_1_0_0_0_0_0_0_0, 4'b0100, 1'b0};
		
		   //fouth stage of most instructions (MOV, ADD, CMP, AND, MVN)
			{`write_rd_mov, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_010_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};	
			{`add_op, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_add, `MNONE, 17'b00_xxx_0_0_1_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`cmp_op, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_status, `MNONE, 17'b00_xxx_0_0_0_1_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`and_op, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_and, `MNONE, 17'b00_xxx_0_0_1_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`write_rd_mvn, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_010_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};
			
			//fifth stage of some instructions (ADD, CMP, AND)
			{`write_rd_add, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_010_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};
			{`write_status, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_1_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`write_rd_and, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_010_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};
			
			//ldr instructions stages
			{`get_rn_ldr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_ldr_addr, `MNONE, 17'b00_001_1_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_ldr_addr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_data_addr_ldr, `MNONE, 17'b00_xxx_0_0_1_0_0_1_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_data_addr_ldr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`read_addr_ldr, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_1, 4'b0100, 1'b0};
			{`read_addr_ldr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_ldr, `MREAD, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`write_rd_ldr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MREAD, 17'b11_010_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0100, 1'b0};
			
			//str instructions stages
			{`get_rn_str, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_str_addr, `MNONE, 17'b00_001_1_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_str_addr, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_data_addr_str, `MNONE, 17'b00_xxx_0_0_1_0_0_1_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_data_addr_str, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_addr_str, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_1, 4'b0100, 1'b0};
			{`write_addr_str, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_rd_str, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rd_str, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`get_rd_out, `MNONE, 17'b00_010_0_1_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`get_rd_out, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`write_rd_str, `MNONE, 17'b00_xxx_0_0_1_0_1_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			{`write_rd_str, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MWRITE, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b0};
			
			//halt instruction
			{`HALT, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`HALT, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_0_0_0_0, 4'b0100, 1'b1};
			
			//branch instructions
			{`BL_0, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BL_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b1000, 1'b0};
			{`BX_0, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BX_1, `MNONE, 17'b00_010_0_1_0_0_0_0_0_0_0_0_0_0, 4'b1000, 1'b0};
			{`BLX_0, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BLX_1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b1000, 1'b0};
			
			{`B_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_1_0_0_0, 4'b0010, 1'b0};
			{`BEQ_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, {Z ? 4'b0010 : 4'b1000}, 1'b0};
			{`BNE_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, {~Z ? 4'b0010 : 4'b1000}, 1'b0};
			{`BLT_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, {(N == V) ? 4'b1000 : 4'b0010}, 1'b0};
			{`BLE_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, {((N != V) | Z) ? 4'b0010 : 4'b1000}, 1'b0};
			
			{`BL_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BL_2, `MNONE, 17'b01_001_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0010, 1'b0};
			{`BX_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BX_2, `MNONE, 17'b00_xxx_0_0_1_0_1_0_0_0_0_0_0_0, 4'b0001, 1'b0};
			{`BLX_1, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`BX_0, `MNONE, 17'b01_001_0_0_0_0_0_0_1_0_0_0_0_0, 4'b0010, 1'b0};
			
			{`BL_2, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b01_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0010, 1'b0};
			{`BX_2, 8'bxxxxxxxx}: {next, branch_sel, halt} = {`IF1, `MNONE, 17'b00_xxx_0_0_0_0_0_0_0_0_1_0_0_0, 4'b0001, 1'b0};
			
			default: {next, branch_sel, halt} = {31{1'bx}};
			
		endcase
		
	end
	
	assign {next_state, mem_cmd, vsel, nsel, loada, loadb, loadc, loads, asel, bsel, write, reset_pc, load_pc, load_ir, addr_sel, load_addr} = next; //writing all bits of next to necessary wires or outputs
	
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
			
	
	