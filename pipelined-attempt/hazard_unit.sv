module hazard_unit(reset, write_reg_mem, write_reg_wb, Rd_mem, Rd_wb, Rm_ex, Rn_ex, Fwd_A, Fwd_B);

	//Initializing I/Os
    input reset, write_reg_mem, write_reg_wb;
	 input [2:0] Rd_mem, Rd_wb, Rm_ex, Rn_ex;
    output [2:0] Fwd_A, Fwd_B;
    
    assign Fwd_A = (reset == 1'b0) ? 3'b010 : 
                       ((write_reg_mem == 1'b1) & (Rd_mem == Rm_ex)) ? 3'b001 :
                       ((write_reg_wb == 1'b1) & (Rd_wb == Rm_ex)) ? 3'b100 : 3'b010;
                       
    assign Fwd_B = (reset == 1'b0) ? 3'b010 : 
                       ((write_reg_mem == 1'b1) & (Rd_mem == Rn_ex)) ? 3'b001 :
                       ((write_reg_wb == 1'b1) & (Rd_wb == Rn_ex)) ? 3'b100 : 3'b010;

endmodule 