module regfile_tb;

  reg [15:0] data_in;
  reg [2:0] writenum,readnum;
  reg write, clk, err;
  wire [15:0] data_out;

  regfile DUT(data_in,writenum,write,readnum,clk,data_out);
  
  task regfile_checker;
	input [15:0] expected_dataout;
	if (data_out !== expected_dataout) begin
      err = 1;
      $display("FAILED: data_out != 0x%h as expected", expected_dataout); 
    end
	 
	endtask
	
  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    err = 0;
    write = 1;
    data_in = 16'h42;
    writenum = 0;
    readnum = 0;
    #10; regfile_checker(16'h42);
	 
	 write = 1;
    data_in = 16'h23;
    writenum = 1;
    readnum = 1;
    #10; regfile_checker(16'h23);
	 
	 write = 1;
    data_in = 16'hF1;
    writenum = 2;
    readnum = 1;
    #10; regfile_checker(16'h23);
	 
	 write = 1;
    data_in = 16'h12;
    writenum = 4;
    readnum = 0;
    #10; regfile_checker(16'h42);
	 
	 write = 1;
    data_in = 16'hFFFF;
    writenum = 5;
    readnum = 5;
    #10; regfile_checker(16'hFFFF);
	 
	 write = 1;
    data_in = 16'h92;
    writenum = 3;
    readnum = 3;
    #10; regfile_checker(16'h92);
	 
	 write = 1;
    data_in = 16'h49;
    writenum = 7;
    readnum = 2;
    #10; regfile_checker(16'hF1);
	 
	 write = 1;
    data_in = 16'h1F3;
    writenum = 6;
    readnum = 1;
    #10; regfile_checker(16'h23);
	 
	 write = 1;
    data_in = 16'h42;
    writenum = 5;
    readnum = 5;
    #10; regfile_checker(16'h42);
	 
	 write = 1;
    data_in = 16'h77;
    writenum = 7;
    readnum = 7;
    #10; regfile_checker(16'h77);
	 
	 write = 0;
    data_in = 16'hEEEE;
    writenum = 1;
    readnum = 0;
    #10; regfile_checker(16'h42);
	 
	 write = 0;
    data_in = 16'h42;
    writenum = 2;
    readnum = 7;
    #10; regfile_checker(16'h77);
	 
	 write = 1;
    data_in = 16'h3A;
    writenum = 3;
    readnum = 5;
    #10; regfile_checker(16'h42);
	 
	end


    initial begin
		 #510;
		 if (err === 0) begin
			$display("PASSED: regfile module works as expected");
		 end 
		$stop;	
		
	end

endmodule

