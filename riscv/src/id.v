`include "Defines.v"

module ID (
    input wire rst,
    input wire[`InstAddrBus] pc_in,
    input wire[`InstBus] inst_in,
    input wire Load_or_not,//stall
    output reg id_stall_out,
//to register 
    output reg rs1_read_out,//0/1
    output reg rs2_read_out,
    output reg[`regaddrbus] rs1_addr_out,
    output reg[`regaddrbus] rs2_addr_out,
//from register 
    input wire[`regbus] rs1_value_in,
    input wire[`regbus] rs2_value_in,


//EX data forwarding 
    input wire ex_forward_or_not,
    input wire[`regbus] ex_forward_value,
    input wire[`regaddrbus] ex_forward_address, 

//MEM data forwarding
    input wire MEM_forward_or_not,
    input wire[`regbus] MEM_forward_value,
    input wire[`regaddrbus] MEM_forward_address, 


    output reg[`InstAddrBus] pc_out,
    output reg[`OpcodeBus] op_out,
    output reg[`Func3Bus] func3_out,
    output reg[`Func7Bus] func7_out,

    output reg[`regbus] rs1_value_out,
    output reg[`regbus] rs2_value_out,

    output reg[`regaddrbus] rd_address_out,
    output reg[`regbus] imm_out,
    output reg if_operate_reg_out,

    output reg[`InstAddrBus] branch_address_out,
    output reg[`InstAddrBus] branch_offset_out


);

    wire[`OpcodeBus] op = inst_in[`OpcodeBus];
    wire[`Func3Bus] func3 = inst_in[14:12];
    wire[`Func7Bus] func7 = inst_in[31:25];
    always @(*) begin
        
    end
    
endmodule