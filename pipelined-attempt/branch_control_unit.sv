module branch_unit(clk, reset, b, beq, bne, blt, ble, bl, bx, blx, N_imm, V_imm, Z_imm, N_load, V_load, Z_load, halt, pc_sel, load_pc, load_if);

	`define RST 4'b0000
	`define HALT_B 4'b0001
	`define HALT_BEQ 4'b0010
	`define HALT_BNE 4'b0011
	`define HALT_BLT 4'b0100
	`define HALT_BLE 4'b0101
	`define HALT_BL 4'b0110
	`define HALT_BX 4'b0111
	`define HALT_BLX 4'b1000
	`define HALT_SYS 4'b1001
	`define UNHALT 4'b1010
	
	//defining I/Os
	input clk, reset, b, beq, bne, blt, ble, bl, bx, blx, N_imm, V_imm, Z_imm, N_load, V_load, Z_load, halt;
	output reg [3:0] pc_sel;
	output reg load_pc, load_if;
	
	wire N_in, V_in, Z_in;
	wire [11:0] fsm_in;
	wire [3:0] present_state, next_state_reset;
	reg [3:0] next_state;

	assign N_in = (N_imm != 1'bx) ? N_imm : N_load;
	assign V_in = (V_imm != 1'bx) ? V_imm : V_load;
	assign Z_in = (Z_imm != 1'bx) ? Z_imm : Z_load;
	
	assign next_state_reset = reset ? `RST : next_state;
	assign fsm_in = {b, beq, bne, blt, ble, bl, bx, blx, N_in, V_in, Z_in, halt};
	
	vDFF #(4) U1(clk, next_state_reset, present_state);
	
	always @(*) begin 
	
		casex({present_state, fsm_in}) 
		
			{`RST, 12'bxxxxxxxxxxx0}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0001, 1'b1, 1'b1};
			{`RST, 12'bxxxxxxxxxxx1}: {next_state, pc_sel, load_pc, load_if} = {`HALT_SYS, 4'b0001, 1'b1, 1'b1};
			
			{`UNHALT, 12'b10000000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_B, 4'b0100, 1'b1, 1'b0};
			{`UNHALT, 12'b01000000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BEQ, Z_in ? 4'b0100 : 4'b0010, 1'b1, 1'b0};
			{`UNHALT, 12'b00100000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BNE, ~Z_in ? 4'b0100 : 4'b0010, 1'b1, 1'b0};
			{`UNHALT, 12'b00010000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BLT, (N_in != V_in) ? 4'b0100 : 4'b0010, 1'b1, 1'b0};
			{`UNHALT, 12'b00001000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BLE, (N_in != V_in) | Z_in ? 4'b0100 : 4'b0010, 1'b1, 1'b0};
			{`UNHALT, 12'b00000100xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BL, 4'b0100, 1'b1, 1'b0};
			{`UNHALT, 12'b00000010xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BX, 4'b1000, 1'b1, 1'b0};
			{`UNHALT, 12'b00000001xxx0}: {next_state, pc_sel, load_pc, load_if} = {`HALT_BLX, 4'b1000, 1'b1, 1'b0};
			{`UNHALT, 12'b00000000xxx1}: {next_state, pc_sel, load_pc, load_if} = {`HALT_SYS, 4'bxxxx, 1'b0, 1'b0};
			{`UNHALT, 12'b00000000xxx0}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			
			{`HALT_B, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BEQ, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BNE, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BLT, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BLE, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BL, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BX, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			{`HALT_BLX, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`UNHALT, 4'b0010, 1'b1, 1'b1};
			
			{`HALT_SYS, 12'bxxxxxxxxxxxx}: {next_state, pc_sel, load_pc, load_if} = {`HALT_SYS, 4'bxxxx, 1'b0, 1'b0};
			
			default: {next_state, pc_sel, load_pc, load_if} = {10{1'bx}};
			
		endcase 
		
	end 
	
endmodule 

	