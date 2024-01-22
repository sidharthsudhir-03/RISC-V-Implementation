module lab7bonus_stage2_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;
  reg CLOCK_50;

  lab7bonus_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);

  initial forever begin
    CLOCK_50 = 0; #5000;
    CLOCK_50 = 1; #5000;
  end
  wire break_1 = (LEDR[8] == 1'b1);
  initial begin
    err = 0;
    KEY[1] = 1'b0; // reset asserted
    #10000; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4
    while (~break_1) begin
      // Change the following line to wait until your CPU starts to you fetch
      // the next instruction (e.g., IF1 state from Lab 7 or equivalent in
      // your design).  DUT.CPU.FSM is not required for by the autograder
      // for Lab 8. 
      @(posedge (DUT.CPU.FSM.present_state == 7'b0000001) or posedge break_1);  

      @(negedge CLOCK_50); // show advance to negative edge of clock
      $display("PC = %h", DUT.CPU.PC); 
    end
	
    if (DUT.MEM.mem[40] !== -16'd23) begin err = 1; $display("FAILED: mem[39] wrong; your value = %d", DUT.MEM.mem[39]); $stop; end
	 if (DUT.CPU.DP.REGFILE.R0 !== -16'd23) begin err = 1; $display("FAILED: contents of R0 wrong; your value = %d", DUT.CPU.DP.REGFILE.R0); $stop; end
	 if (DUT.CPU.DP.REGFILE.R1 !== 16'd5) begin err = 1; $display("FAILED: contents of R1 wrong; your value = %d", DUT.CPU.DP.REGFILE.R1); $stop; end
	 if (DUT.CPU.DP.REGFILE.R2 !== 16'd9) begin err = 1; $display("FAILED: contents of R2 wrong; your value = %d", DUT.CPU.DP.REGFILE.R2); $stop; end
	 if (DUT.CPU.DP.REGFILE.R3 !== 16'd1) begin err = 1; $display("FAILED: contents of R3 wrong; your value = %d", DUT.CPU.DP.REGFILE.R3); $stop; end
	 if (DUT.CPU.DP.REGFILE.R4 !== 16'd40) begin err = 1; $display("FAILED: contents of R4 wrong; your value = %d", DUT.CPU.DP.REGFILE.R4); $stop; end
	 if (DUT.CPU.DP.REGFILE.R5 !== {16{1'bx}}) begin err = 1; $display("FAILED: contents of R5 wrong; your value = %d", DUT.CPU.DP.REGFILE.R5); $stop; end
	 if (DUT.CPU.DP.REGFILE.R6 !== 16'd255) begin err = 1; $display("FAILED: contents of R6 wrong; your value = %d", DUT.CPU.DP.REGFILE.R6); $stop; end
	 if (DUT.CPU.DP.REGFILE.R7 !== 16'd10) begin err = 1; $display("FAILED: contents of R7 wrong; your value = %d", DUT.CPU.DP.REGFILE.R7); $stop; end
    if (~err) $display("PASSED");
    $stop;
  end
endmodule
