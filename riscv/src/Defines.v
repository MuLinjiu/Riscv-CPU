// 全局宏定义

`define rst_enable          1'b1
`define rst_disable         1'b0
`define zeroword            32'h00000000
`define write_enable        1'b1
`define write_disable       1'b0
`define read_enable         1'b1
`define read_disable        1'b0
`define inst_valid          1'b0
`define inst_invalid        1'b1
`define true_v              1'b1
`define false_v             1'b0
`define InstAddrBus         31:0
`define InstBus             31:0
`define stallbus            4:0//0for if ,1 for id 2 for ex 3 for mem 4 for wb
`define OpcodeBus           6:0
`define Func3Bus            2:0
`define Func7Bus            6:0


//register
`define regbus              31:0
`define regaddrbus          4:0
`define regwidth            32
`define regnum              32
`define Nopreg              5'b00000
`define zeroreg             5'h0


//opcode 
`define opcode_range        6:0
`define opcodewidth         7




`define OP_LUI              7'b0110111
`define OP_AUIPC            7'b0010111
`define OP_JAL              7'b1101111
`define OP_JALR             7'b1100111
`define OP_BRANCH           7'b1100011
`define OP_LOAD             7'b0000011
`define OP_STORE            7'b0100011
`define OP_OP_IMM           7'b0010011
`define OP_OP               7'b0110011
`define OP_MISC_MEM         7'b0001111
`define OP_NON              7'b0000000

