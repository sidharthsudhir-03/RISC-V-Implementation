module lab7bonus_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

	//initializing I/Os
	input[3:0]KEY; 
	input[9:0]SW;
	input CLOCK_50;
	output[9:0]LEDR; 
	output[6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	
	//wire instantiations
	wire dout_en, sw_en, ledr_load;
	
	//cpu I/O ports
	reg [15:0] read_data_cpu;
	wire [1:0] mem_cmd;
	wire [8:0] mem_addr;
	wire [15:0] write_data;
	wire N, V, Z;
	
	//ram I/O ports
	reg [7:0] read_address, write_address;
	reg [15:0] din;
	reg write;
	wire [15:0] dout;
	
	//module instantiation 
	cpu CPU(CLOCK_50, ~KEY[1], read_data_cpu, mem_cmd, mem_addr, write_data, N, V, Z, LEDR[8]);
	ram MEM(CLOCK_50,read_address,write_address,write,din,dout);
	vDFFE #(8) LED_R(CLOCK_50, ledr_load, write_data[7:0], LEDR[7:0]);

	
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = {35{1'b1}}; //disabled
	assign LEDR[9] = 1'b0; //disabled
	assign dout_en = (mem_cmd == 2'b10) & (mem_addr[8] == 1'b0); //combinational logic block to assign enable value for reading value from memory
	assign sw_en =  (mem_cmd == 2'b10) & (mem_addr == 9'h140); //combinational logic block to assign enable value for reading slider input
	assign ledr_load = (mem_cmd == 2'b11) & (mem_addr == 9'h100); //combinational logic block to assign enable value for LEDR load register
	
	always_comb begin

		read_address = mem_addr[7:0];
		write_address = mem_addr[7:0];
		din = write_data;
		read_data_cpu = dout_en ? dout : sw_en ? {8'b0, SW[7:0]} : 16'b0; //combinational logic to determine read_addr between dout and slider input
		write = (mem_cmd == 2'b11) & (mem_addr[8] == 1'b0); //combinational logic to determine read_addr 
		
	end
	
endmodule







