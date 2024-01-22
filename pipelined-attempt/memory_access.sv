module memory_access(clk, ALU_data, mem_cmd, sw_in, wb_dout, led_out);

	//initializing I/Os
	input reg clk;
	input reg[15:0] ALU_data;
	input [7:0] sw_in;
	input[1:0] mem_cmd;
	output reg[15:0] wb_dout;
	output [7:0] led_out;
	
	wire[15:0] dout;
	wire dout_en, sw_en, ledr_load;
	reg write;
	
	assign dout_en = (mem_cmd == 2'b10) & (ALU_data[8] == 1'b0); //combinational logic block to assign enable value for reading value from memory
	assign sw_en =  (mem_cmd == 2'b10) & (ALU_data[8:0] == 9'h140); //combinational logic block to assign enable value for reading slider input
	assign ledr_load = (mem_cmd == 2'b11) & (ALU_data[8:0] == 9'h100); //combinational logic block to assign enable value for LEDR load register
	
	ram MEM(clk,ALU_data[7:0],ALU_data[7:0],write,ALU_data,dout);
	vDFFE #(8) LED_R(clk, ledr_load, wb_dout[7:0], led_out);
	
	always_comb begin 
	
		write = (mem_cmd == 2'b11) & (ALU_data[8] == 1'b0);
		wb_dout = dout_en ? dout : sw_en ? {8'b0, sw_in} : 16'b0;
	end
	
endmodule 

	