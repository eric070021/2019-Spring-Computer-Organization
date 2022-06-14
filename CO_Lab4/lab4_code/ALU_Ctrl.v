//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [5:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter
always@(funct_i, ALUOp_i)begin
    ALUCtrl_o[0]=(ALUOp_i[1] | (~(ALUOp_i[3] | ALUOp_i[2] | ALUOp_i[1]) & (funct_i[0] | funct_i[3]))) & ~ALUOp_i[5];
    ALUCtrl_o[1]=~(~(ALUOp_i[3] | ALUOp_i[2] | ALUOp_i[1]) & (funct_i[2] | funct_i[4]));
    ALUCtrl_o[2]=(ALUOp_i[1] | ALUOp_i[2] | (~(ALUOp_i[3] | ALUOp_i[2] | ALUOp_i[1]) & (funct_i[1] | funct_i[4]))) & ~ALUOp_i[5];
    ALUCtrl_o[3]=(~(ALUOp_i[3] | ALUOp_i[2] | ALUOp_i[1]) & funct_i[4]);
//Select exact operation
end
endmodule     





                    
                    