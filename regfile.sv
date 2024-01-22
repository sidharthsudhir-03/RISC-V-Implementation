module regfile(data_in,writenum,write,readnum,clk,data_out);

	//initialzing inputs
	input reg[15:0] data_in;
	input reg[2:0] writenum, readnum;
	input write, clk;
	
	//initializing output
	output reg[15:0] data_out;

	wire [7:0] writenum_onebit, readnum_onebit; 
	wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7; //ouput wire from load registers
	reg [7:0] w_en; //one hot select reg write which is input into load register

	assign writenum_onebit = 8'b00000001 << writenum;
	assign readnum_onebit = 8'b000000001 << readnum;

	vDFFE #(16)LR1(clk, w_en[0], data_in, R0); //load value of R0
	vDFFE #(16)LR2(clk, w_en[1], data_in, R1); //load value of R1
	vDFFE #(16)LR3(clk, w_en[2], data_in, R2); //load value of R2
	vDFFE #(16)LR4(clk, w_en[3], data_in, R3); //load value of R3
	vDFFE #(16)LR5(clk, w_en[4], data_in, R4); //load value of R4
	vDFFE #(16)LR6(clk, w_en[5], data_in, R5); //load value of R5
	vDFFE #(16)LR7(clk, w_en[6], data_in, R6); //load value of R6
	vDFFE #(16)LR8(clk, w_en[7], data_in, R7); //load value of R7

	always_comb begin
		
		w_en = writenum_onebit & {8{write}}; //writes to specific register only if write is high
		
		//one hot select mux for determining data_out
		case(readnum_onebit)
			8'b00000001: data_out = R0;
			8'b00000010: data_out = R1;
			8'b00000100: data_out = R2;
			8'b00001000: data_out = R3;
			8'b00010000: data_out = R4;
			8'b00100000: data_out = R5;
			8'b01000000: data_out = R6;
			8'b10000000: data_out = R7;
			default: data_out = {16{1'bx}};
		endcase
	end


endmodule

//load enable register module
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



