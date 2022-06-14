//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire [31:0]pc_out;
wire [31:0]pc_next;
wire [31:0]pc_back;
wire [31:0]pc_cal;
wire [31:0]pc_cal2;
wire [31:0]pc_cal3;
wire [31:0]instr_o;
wire [31:0]result;
wire [31:0]regresult;

wire [31:0]RSdata;
wire [31:0]RTdata;
wire [31:0]extend;
wire [31:0]muxalu;
wire [31:0]extend2;
wire [31:0]redmonster;

wire [4:0]WriteReg1;
wire [4:0]WriteData;
wire [4:0]ReadReg1;
wire [4:0]ReadReg2;

wire [3:0]ALU_control;
wire [5:0]ALU_op;

wire [1:0]regdst;
wire regwrite;
wire branch;
wire ALUSrc;
wire zero;
wire memread;
wire memwrite;
wire [1:0]memtoreg;
wire jump;

assign jumpjr=((instr_o[31:26] == 6'b000000) && (instr_o[20:0] == 8));
//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_back) ,   
	    .pc_out_o(pc_out) 
	    );
	
Adder Adder1(
        .src1_i(pc_out),     
	    .src2_i(32'd4),     
	    .sum_o(pc_next)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out),  
	    .instr_o(instr_o)    
	    );

MUX_3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .data2_i(5'd31),
        .select_i(regdst),
        .data_o(WriteReg1)
        );	
		
Reg_File Registers(
        .clk_i(clk_i),      
	    .rst_i(rst_i) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(WriteReg1) ,  
        .RDdata_i(regresult)  , 
        .RegWrite_i (regwrite),
        .RSdata_o(RSdata) ,  
        .RTdata_o(RTdata)   
        );
	
Decoder Decoder(
        .instr_op_i(instr_o[31:26]), 
	    .RegWrite_o(regwrite), 
	    .ALU_op_o(ALU_op),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(regdst),   
		.Branch_o(branch),
                .Memread_o(memread),
	        .Memwrite_o(memwrite),
	        .Memtoreg_o(memtoreg),
	        .jump_o(jump) 
	    );

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALU_op),   
        .ALUCtrl_o(ALU_control) 
        );
	
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(extend)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata),
        .data1_i(extend),
        .select_i(ALUSrc),
        .data_o(muxalu)
        );	
		
ALU ALU(
        .src1_i(RSdata),
	    .src2_i(muxalu),
	    .ctrl_i(ALU_control),
	    .result_o(result),
		.zero_o(zero)
	    );
	
Data_Memory Data_Memory(
	.clk_i(clk_i),
	.addr_i(result),
	.data_i(RTdata),
	.MemRead_i(memread),
	.MemWrite_i(memwrite),
	.data_o(redmonster)
	);
	
MUX_3to1 #(.size(32)) memdatamux(
        .data0_i(result),
        .data1_i(redmonster),
        .data2_i(pc_next),
        .select_i(memtoreg),
        .data_o(regresult)
        );	

Adder Adder2(
        .src1_i(pc_next),     
	    .src2_i(extend2),     
	    .sum_o(pc_cal)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(extend),
        .data_o(extend2)
        ); 		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(RSdata),
        .data1_i({pc_next[31:28],instr_o[25:0],2'b00}),
        .select_i(jump),
        .data_o(pc_cal3)
        );	

MUX_2to1 #(.size(32)) Mux_PC_Source2(
        .data0_i(pc_next),
        .data1_i(pc_cal),
        .select_i(branch && zero),
        .data_o(pc_cal2)
        );	
		
MUX_2to1 #(.size(32)) Mux_PC_Source3(
        .data0_i(pc_cal2),
        .data1_i(pc_cal3),
        .select_i((jumpjr && ~jump) || jump),
        .data_o(pc_back)
        );	
endmodule
		  


