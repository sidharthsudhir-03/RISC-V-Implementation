module rom(pc_addr, read_data);

	parameter filename = "data.txt";
	
	//defining I/Os
	input[7:0] pc_addr;
	output reg[15:0] read_data;
	
	reg [15:0] mem [255:0]; //this bus array holds all the instructions from the 'data.txt' files	
	
	initial $readmemb(filename, mem);	//reads instruction into mem bus array	
	
	always @(pc_addr) begin
    
	 read_data <= mem[pc_addr]; // Read data from memory

	end
	
endmodule 