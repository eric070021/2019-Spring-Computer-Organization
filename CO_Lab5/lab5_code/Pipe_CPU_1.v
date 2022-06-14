`timescale 1ns / 1ps
//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/









wire [4:0]ReadReg1;
wire [4:0]ReadReg2;





/**** IF stage ****/
wire pc_write;
wire [31:0]pc_out;
wire [31:0]pc_next;
wire [31:0]pc_back;
wire [31:0]instr_o;

wire if_id_flush;
wire [31:0]if_id_pc_next;
wire [31:0]if_id_instr_o;
/**** ID stage ****/
wire [1:0]regdst;
wire regwrite;
wire branch;
wire ALUSrc;
wire memread;
wire memwrite;
wire [5:0]ALU_op;
wire [1:0]memtoreg;
wire [31:0]RSdata;
wire [31:0]RTdata;
wire [31:0]extend;

wire [1:0]ID_EX_regdst;
wire ID_EX_regwrite;
wire ID_EX_branch;
wire ID_EX_ALUSrc;
wire ID_EX_zero;
wire ID_EX_memread;
wire ID_EX_memwrite;
wire [1:0]Branchtype;
wire [5:0]ID_EX_ALU_op;
wire [1:0]ID_EX_memtoreg;
wire [31:0]ID_EX_RSdata;
wire [31:0]ID_EX_RTdata;
wire [31:0]ID_EX_extend;
wire [31:0]ID_EX_pc_next;
wire [31:0]ID_EX_instr_o;

/**** EX stage ****/
wire [31:0]pc_cal;
wire [31:0]result;
wire zero;
wire [31:0]muxalu;
wire [31:0]extend2;
wire [3:0]ALU_control;
wire [4:0]WriteReg1;

wire branchsatis;
wire [2-1:0] Forward_A;
wire [2-1:0] Forward_B;
wire EX_MEM_regwrite;
wire EX_MEM_branch;
wire EX_MEM_memread;
wire EX_MEM_memwrite;
wire [1:0]EX_MEM_memtoreg;
wire [31:0]EX_MEM_pc_cal;
wire EX_MEM_zero;
wire [31:0]EX_MEM_result;
wire [31:0]EX_MEM_RTdata;
wire [4:0]EX_MEM_WriteReg1;
wire [32-1:0] ALUSrc1_Forward;
wire [32-1:0] ALUSrc2_Forward;
/**** MEM stage ****/
wire [31:0]redmonster;

wire MEM_WB_regwrite;
wire [1:0]MEM_WB_memtoreg;
wire [4:0]MEM_WB_WriteReg1;
wire [31:0]MEM_WB_result;
wire [31:0]MEM_WB_redmonster;
/**** WB stage ****/
wire [31:0]regresult;



/****************************************
Instantiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux0(
        .data0_i(pc_next),
        .data1_i(EX_MEM_pc_cal),
        .select_i(branchsatis && ID_EX_branch),
        .data_o(pc_back)
);

ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i), 
            .pc_write_i(pc_write),    
	    .pc_in_i(pc_back) ,   
	    .pc_out_o(pc_out) 
);

Instruction_Memory IM(
     .addr_i(pc_out),
     .instr_o(instr_o)
);
			
Adder Add_pc(
     .src1_i(pc_out),
     .src2_i(4),
     .sum_o(pc_next)
);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush_i(if_id_flush || (branchsatis && ID_EX_branch)),
    .data_i({pc_next,instr_o}),
    .data_o({if_id_pc_next,if_id_instr_o})
);


//Instantiate the components in ID stage
Reg_File RF(
        .clk_i(clk_i),      
	.rst_i(rst_i) ,     
        .RSaddr_i(if_id_instr_o[25:21]) ,  
        .RTaddr_i(if_id_instr_o[20:16]) ,  
        .RDaddr_i(MEM_WB_WriteReg1) ,  
        .RDdata_i(regresult)  , 
        .RegWrite_i (MEM_WB_regwrite),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
);

Decoder Control(
        .instr_op_i(if_id_instr_o[31:26]), 
	.RegWrite_o(regwrite), 
	.ALU_op_o(ALU_op),   
	.ALUSrc_o(ALUSrc),   
	.RegDst_o(regdst),   
        .Branch_o(branch),
        .Branchtype(Branchtype),
        .Memread_o(memread),
	.Memwrite_o(memwrite),
	.Memtoreg_o(memtoreg)
);

Sign_Extend Sign_Extend(
        .data_i(if_id_instr_o[15:0]),
        .data_o(extend)
);	

Pipe_Reg #(.size(175)) ID_EX(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .flush_i(if_id_flush || (branchsatis && ID_EX_branch)),
        .data_i({regwrite,ALU_op,ALUSrc,regdst,branch,memread,memwrite,memtoreg,extend,
                RSdata,RTdata,if_id_pc_next,if_id_instr_o}),
        .data_o({ID_EX_regwrite,ID_EX_ALU_op,ID_EX_ALUSrc,ID_EX_regdst,ID_EX_branch,ID_EX_memread,ID_EX_memwrite,ID_EX_memtoreg
                ,ID_EX_extend,ID_EX_RSdata,ID_EX_RTdata,ID_EX_pc_next,ID_EX_instr_o})
);


//Instantiate the components in EX stage
HazardDetect Hazard(
                        .ID_EX_MemRead_i(ID_EX_memread),
			.ID_EX_RT_i(ID_EX_instr_o[20:16]),
			.IF_ID_RS_i(if_id_instr_o[25:21]),
			.IF_ID_RT_i(if_id_instr_o[20:16]),
			.pc_write_o(pc_write),
			.IF_ID_flush_o(if_id_flush)
			);
Forward Forwarding(
                        .EX_MEM_RegWrite_i(EX_MEM_regwrite),
			.EX_MEM_writeReg1_i(EX_MEM_WriteReg1),
			.MEM_WB_RegWrite_i(MEM_WB_regwrite),
			.MEM_WB_writeReg1_i(MEM_WB_WriteReg1),
			.ID_EX_RS_i(ID_EX_instr_o[25:21]),
			.ID_EX_RT_i(ID_EX_instr_o[20:16]),
			.Forward_A_o(Forward_A),
			.Forward_B_o(Forward_B)
			);

Shift_Left_Two_32 Shifter(
        .data_i(ID_EX_extend),
        .data_o(extend2)
);

ALU ALU(
        .src1_i(ALUSrc1_Forward),
	.src2_i(ALUSrc2_Forward),
	.ctrl_i(ALU_control),
	.result_o(result),
        .zero_o(zero)
);
		
ALU_Ctrl ALU_Control(
        .funct_i(ID_EX_instr_o[5:0]),   
        .ALUOp_i(ID_EX_ALU_op),   
        .ALUCtrl_o(ALU_control) 
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(ID_EX_RTdata),
        .data1_i(ID_EX_extend),
        .select_i(ID_EX_ALUSrc),
        .data_o(muxalu)
);

MUX_3to1 #(.size(32)) MuxALUSrc1(
                        .data0_i(EX_MEM_result),
			.data1_i(regresult),
			.data2_i(ID_EX_RSdata),
			.select_i(Forward_A),
			.data_o(ALUSrc1_Forward)
                        );

MUX_3to1 #(.size(32)) MuxALUSrc2(
                        .data0_i(EX_MEM_result),
			.data1_i(regresult),
			.data2_i(muxalu),
			.select_i(Forward_B),
			.data_o(ALUSrc2_Forward)
                        );

MUX_3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ID_EX_instr_o[20:16]),
        .data1_i(ID_EX_instr_o[15:11]),
        .data2_i(5'd31),
        .select_i(ID_EX_regdst),
        .data_o(WriteReg1)
        );	

Adder Add_pc_branch(
        .src1_i(ID_EX_pc_next),     
	    .src2_i(extend2),     
	    .sum_o(pc_cal)   
);

MUX_4to1 #(.size(1)) muxbranch(
        .data0_i(ID_EX_RSdata > ID_EX_RTdata),
        .data1_i(ID_EX_RSdata >= ID_EX_RTdata),
        .data2_i(ID_EX_RSdata != ID_EX_RTdata),
        .data3_i(ID_EX_RSdata == ID_EX_RTdata),
        .select_i(Branchtype),
        .data_o(branchsatis)
);

Pipe_Reg #(.size(108)) EX_MEM(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .flush_i(1'b0),
        .data_i({ID_EX_regwrite,ID_EX_branch,ID_EX_memread,ID_EX_memwrite,ID_EX_memtoreg,pc_cal,branchsatis,
                result,ID_EX_RTdata,WriteReg1}),
        .data_o({EX_MEM_regwrite,EX_MEM_branch,EX_MEM_memread,EX_MEM_memwrite,EX_MEM_memtoreg,
                EX_MEM_pc_cal,EX_MEM_branchsatis,EX_MEM_result,EX_MEM_RTdata,EX_MEM_WriteReg1})
);


//Instantiate the components in MEM stage
Data_Memory DM(
        .clk_i(clk_i),
	    .addr_i(EX_MEM_result),
	    .data_i(EX_MEM_RTdata),
	    .MemRead_i(EX_MEM_memread),
	    .MemWrite_i(EX_MEM_memwrite),
	    .data_o(redmonster)
);

Pipe_Reg #(.size(72)) MEM_WB(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .flush_i(1'b0),
        .data_i({EX_MEM_regwrite,EX_MEM_memtoreg,EX_MEM_WriteReg1,EX_MEM_result,redmonster}),
        .data_o({MEM_WB_regwrite,MEM_WB_memtoreg,MEM_WB_WriteReg1,MEM_WB_result,MEM_WB_redmonster})
);


//Instantiate the components in WB stage
MUX_3to1 #(.size(32)) Mux3(
        .data0_i(MEM_WB_result),
        .data1_i(MEM_WB_redmonster),
        .data2_i(pc_next),
        .select_i(MEM_WB_memtoreg),
        .data_o(regresult)
);

/****************************************
signal assignment
****************************************/

endmodule

