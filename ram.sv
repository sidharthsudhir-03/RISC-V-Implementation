module ram(clk,read_address,write_address,write,din,dout);
  parameter data_width = 16; 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  //Initializing I/Os
  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0]; //this bus array holds all the instructions from the 'data.txt' files

  initial $readmemb(filename, mem); //reads instruction into mem bus array

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
 
endmodule 