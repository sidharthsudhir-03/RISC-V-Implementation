module datapath(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata, sximm8, sximm5, PC, N, V, Z, out);

	//initializing all inputs
	input [15:0] mdata, sximm8, sximm5;
	input[7:0] PC;
	input reg loada, loadb, loadc, loads, asel, bsel, write;
	input[1:0] vsel;
	input clk;
	input reg [2:0] readnum, writenum;
	input reg[1:0] shift, ALUop;
	
	//initializing all outputs
	output N, V, Z;
	output [15:0] out;
	
	
	//initializing all necessary wires and regs to avoid illegal declaration
	reg [15:0] data_in, data_out, Ain, Bin, in, out_load; //all necessary inputs to different instantiated modules
	wire [15:0] data_regfile, ALUout, data_outa, data_outb, sout; //all necessary outputs to different instantiated modules
	wire[2:0] status, status_out;
	reg [2:0] status_in; 
	wire[15:0] C; //formerly datapath_out
	
	vDFFE #(16)LR1(clk, loada, data_out, data_outa); //loada register
	vDFFE #(16)LR2(clk, loadb, data_out, data_outb); //loadb register
	vDFFE #(16)LR3(clk, loadc, out_load, C);   //loadc register
	vDFFE #(3) LR4(clk, loads, status_in, status_out); //loads register
	
	regfile REGFILE(data_in,writenum,write,readnum,clk,data_regfile); //regfile module
	shifter SHIFTER(in, shift, sout); //shifter module
	ALU ALU(Ain, Bin, ALUop, ALUout, status); //alu module
	
	//The primary purpose of this always_comb block is to convert the output wire from one module into an
	//input reg into another module
	
	always_comb begin
	
		data_in = (vsel[1] == 1) ? ((vsel[0] == 1) ? mdata : sximm8) : ((vsel[0] == 1) ? {{8{1'b0}}, PC} : C); 
		data_out = data_regfile; //output from regfile to input to loada or loadb register
		in = data_outb; //output from loadb register to input for shifter module
		Ain = asel ? {16{1'b0}} : data_outa;
		Bin = bsel ? sximm5 : sout; //change made to B mux
		out_load = ALUout; // output wire from ALU module to input reg for loadc register
		status_in = status; //Z output wire from ALU module as input reg for loads register
		
	end
	
	//three bit status values written to N, V, and Z respectively
	assign N = status_out[2];
	assign V = status_out[1];
	assign Z = status_out[0];
	assign out = C;
	
		

endmodule:datapath