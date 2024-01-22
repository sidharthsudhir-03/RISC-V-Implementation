module ALU(Ain,Bin,ALUop,out,status);

	//initializing inputs
	input reg[15:0] Ain, Bin;
	input reg[1:0] ALUop;

	//initializing outputs
	output reg [15:0] out;
	output reg[2:0] status;
	
	wire [15:0] cmp_out;
	assign cmp_out = Ain - Bin; //this is to identify the flags when performing the CMP operation, i.e. zero, overflow, and negative flags

always_comb begin 

   //different alu operations to be executed based on ALUop
	case(ALUop)
		2'b00: {out, status} = {Ain + Bin, 3'bxxx};
		2'b01: {out, status} = {{16{1'bx}}, (cmp_out[15] == 1'b1) ? 1'b1 : 1'b0, (Ain[15] & ~Bin[15] & ~cmp_out[15]) | (~Ain[15] & Bin[15] & cmp_out[15]), (cmp_out[15:0] == {16{1'b0}}) ? 1'b1 : 1'b0} ;
		2'b10: {out, status} = {Ain & Bin, 3'bxxx};
		2'b11: {out, status} = {~Bin, 3'bxxx};	
		default: {out, status} = {19{1'bx}};
	endcase
	
	
end		

endmodule 




