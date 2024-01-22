module ALU_tb();

  reg [15:0] Ain, Bin;
  reg err;
  reg [1:0] ALUop;
  wire [15:0] aout;
  wire Z;

  ALU DUT(Ain,Bin,ALUop,aout,Z);
  
  task alu_checker;
	input[15:0] expected_aout;
	input expected_Z;
	
	if (aout !== expected_aout) begin
      err = 1;
      $display("FAILED: ALU output != 0x%h as expected", expected_aout); 
   end
	 
	if (Z !== expected_Z) begin
      err = 1;
      $display("FAILED: ALU zero detect != %b as expected", expected_Z); 
    end
	endtask 

  initial begin
    err = 0;
    Ain = 16'h42;
    Bin = 16'h13;
	 
    ALUop = 2'b00;
    #10; alu_checker(16'h55, 1'b0);
	 
	 ALUop = 2'b01;
	 #10; alu_checker(16'h2F, 1'b0);
	 
	 ALUop = 2'b10;
	 #10; alu_checker(16'h2, 1'b0);
	 
	 ALUop = 2'b11;
	 #10; alu_checker(16'hFFEC, 1'b0);
	 
	 
	 Ain = 16'hFFFE;
	 Bin = 16'h1;
	 
	 ALUop = 2'b00;
    #10; alu_checker(16'hFFFF, 1'b0);
	 
	 ALUop = 2'b01;
	 #10; alu_checker(16'hFFFD, 1'b0);
	 
	 ALUop = 2'b10;
	 #10; alu_checker(16'h0, 1'b1);
	 
	 ALUop = 2'b11;
	 #10; alu_checker(16'hFFFE, 1'b0);
	 
	 
	 Ain = 16'hFFFF;
	 Bin = 16'h1;
	 
	 ALUop = 2'b00;
    #10; alu_checker(16'h0, 1'b1);
	 
	 ALUop = 2'b01;
	 #10; alu_checker(16'hFFFE, 1'b0);
	 
	 ALUop = 2'b10;
	 #10; alu_checker(16'h1, 1'b0);
	 
	 ALUop = 2'b11;
	 #10; alu_checker(16'hFFFE, 1'b0);
	 
	 Ain = 16'hFFFF;
	 Bin = 16'hFFFF;
	 
	 ALUop = 2'b00;
    #10; alu_checker(16'hFFFE, 1'b0);
	 
	 ALUop = 2'b01;
	 #10; alu_checker(16'h0, 1'b1);
	 
	 ALUop = 2'b10;
	 #10; alu_checker(16'hFFFF, 1'b0);
	 
	 ALUop = 2'b11;
	 #10; alu_checker(16'h0, 1'b1);
	 
	 
	end


    initial begin
		 #510;
		 if (err === 0) begin
			$display("PASSED: ALU module works as expected");
		 end 
		$stop;	
		
	end

endmodule
	 

    