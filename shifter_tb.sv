module shifter_tb;

  reg [15:0] in;
  reg clk, err;
  reg [1:0] shift;
  wire [15:0] sout;

  shifter DUT(in,shift,sout);
  
  task shifter_check;
	input [15:0] expected_sout;

	
	if (sout !== expected_sout) begin
      err = 1;
      $display("FAILED: shifter output = %b, expected output = %b", sout, expected_sout); 
    end
	 
	else begin
		$display("PASSED: shifter output = %b, expected output = %b", sout, expected_sout); 
		
	end
  endtask
	

  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

  initial begin
    err = 0;
    in = 16'b1011101010110111;
    shift = 2'd0;
    #10; shifter_check(16'b1011101010110111);
	 
	 shift = 2'd1;
	 #10; shifter_check(16'b0111010101101110);
	 
	 shift = 2'd2;
	 #10; shifter_check(16'b0101110101011011);
	 
	 shift = 2'd3;
	 #10; shifter_check(16'b1101110101011011);
	 
	 in = 16'b1111000011001111;
	 shift = 2'd0;
	 #10; shifter_check(16'b1111000011001111);
	 
	 shift = 2'd1;
	 #10; shifter_check(16'b1110000110011110);
	 
	 shift = 2'd2;
	 #10; shifter_check(16'b0111100001100111);
	 
	 shift = 2'd3;
	 #10; shifter_check(16'b1111100001100111);
	 
	 in = 16'b1111111111111111;
	 shift = 2'd0;
	 #10; shifter_check(16'b1111111111111111);
	 
	 shift = 2'd1;
	 #10; shifter_check(16'b1111111111111110);
	 
	 shift = 2'd2;
	 #10; shifter_check(16'b0111111111111111);
	 
	 shift = 2'd3;
	 #10; shifter_check(16'b1111111111111111);
	 
	end


    initial begin
		 #510;
		 if (err === 0) begin
			$display("PASSED: regfile module works as expected");
		 end 
		$stop;	
		
	end

endmodule
