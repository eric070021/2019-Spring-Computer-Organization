//Subject:     CO project 2 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      Luke
//----------------------------------------------
//Date:        2010/8/16
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	Memread_o,
	Memwrite_o,
	Memtoreg_o,
	jump_o
	);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [5:0] ALU_op_o;
output         ALUSrc_o;
output [1:0]   RegDst_o;
output         Branch_o;
output  	   Memread_o;
output  	   Memwrite_o;
output [1:0]   Memtoreg_o;
output  	   jump_o;
 
//Internal Signals
/*
reg    [4-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg    [1:0]   RegDst_o;
reg            Branch_o;
reg  	  	   Memread_o;
reg  	       Memwrite_o;
reg  	[1:0]  Memtoreg_o;
reg  	       jump_o;
*/
//Parameter
assign ALU_op_o=instr_op_i[5:0];
assign	Branch_o=instr_op_i[2];
assign	ALUSrc_o=(instr_op_i[3] == 1 || instr_op_i == 6'b100011) ;
assign	RegWrite_o= (instr_op_i == 6'b000100 || instr_op_i == 6'b101011 || instr_op_i == 6'b000010) ? 1'b0: 1'b1; 
assign	Memtoreg_o=(instr_op_i == 6'b100011) ? 2'd1 :((instr_op_i == 6'b000011)? 2'd2: 2'd0);
assign	RegDst_o=(instr_op_i == 0) ? 2'd1 :((instr_op_i == 6'b000011) ? 2'd2 : 2'd0);
assign	Memread_o=(instr_op_i == 6'b100011);
assign	Memwrite_o=(instr_op_i == 6'b101011);
assign	jump_o=(instr_op_i[5:1] == 5'b00001);

//Main function

endmodule





                    
                    