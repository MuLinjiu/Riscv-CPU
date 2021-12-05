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


//icache
`define icachenum           128
`define icachebus           6:0
`define icachetagbus        9:0
`define tagbytes            16:7

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
`define opLUI               7'b0110111
`define opAUIPC             7'b0010111
`define opJAL               7'b1101111
`define opJALR              7'b1100111
`define opBranch            7'b1100011
`define opLoad              7'b0000011
`define opStore             7'b0100011
`define opI                 7'b0010011
`define opR                 7'b0110011
`define OP_NON              7'b0000000

`define STALL               6'b000000
`define LUI                 6'b000001
`define AUIPC               6'b000010
`define JAL                 6'b000011
`define JALR                6'b000100
`define BEQ                 6'b000101
`define BNE                 6'b000110
`define BLT                 6'b000111
`define BGE                 6'b001000
`define BLTU                6'b001001
`define BGEU                6'b001010
`define LB                  6'b001011
`define LH                  6'b001100
`define LW                  6'b001101
`define LBU                 6'b001110
`define LHU                 6'b001111
`define SB                  6'b010000
`define SH                  6'b010001
`define SW                  6'b010010
`define ADDI                6'b010011
`define SLTI                6'b010100
`define SLTIU               6'b010101
`define XORI                6'b010110
`define ORI                 6'b010111
`define ANDI                6'b011000
`define SLLI                6'b011001
`define SRLI                6'b011010
`define SRAI                6'b011011
`define ADD                 6'b011100
`define SUB                 6'b011101
`define SLL                 6'b011110
`define SLT                 6'b011111
`define SLTU                6'b100000
`define XOR                 6'b100001
`define SRL                 6'b100010
`define SRA                 6'b100011
`define OR                  6'b100100
`define AND                 6'b100101
