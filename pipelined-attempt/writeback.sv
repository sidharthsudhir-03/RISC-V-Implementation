module writeback (vsel, mdata, alu, pc1_wb, write_data);

	//defining I/Os
	input [2:0] vsel;
	input [15:0] mdata, alu;
	input [7:0] pc1_wb;
	output reg[15:0] write_data;
	
	
	always_comb begin 
	
		case(vsel) 
		
			3'b001: write_data = alu;
			3'b010: write_data = mdata;
			3'b100: write_data = {8'b0, pc1_wb};
			default: write_data = {16{1'bx}};
			
		endcase
		
	end
	
endmodule
			
	