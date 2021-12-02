`include "Defines.v"

module ID_EX (
    input wire clk,
    input wire rst,
    input wire jump_or_not,
    //ID
    input wire[`regbus] rs1_value_in,
    input wire[`regbus] rs2_value_in,
    input wire[`regaddrbus] rd_address_in,
    input wire[`regbus] imm_in,
    input wire[`regbus] branch_address_in,
    input wire[`regbus] branch_offset_in,

    input wire[5:0] op_in,
    input wire[`InstAddrBus] pc_in,

    input wire[`stallbus] stall_in,
    //to EX
    output reg[5:0] op_out,
    output reg[`InstAddrBus] pc_out,
    output reg[`regbus] rs1_value_out,
    output reg[`regbus] rs2_value_out,
    output reg[`regaddrbus] rd_address_out,
    output reg[`regbus] imm_out,
    output reg[`regbus] branch_address_out,
    output reg[`regbus] branch_offset_out
);
    always @(posedge clk) begin
        if(rst == `rst_enable || (stall_in[2] && !stall_in[3]) || jump_or_not)begin
            op_out <= `STALL;
            pc_out <= `zeroword;
            rs1_value_out <= `zeroword;
            rs2_value_out <= `zeroword;
            rd_address_out <= `Nopreg;
            imm_out <= `zeroword;
            branch_address_out <= `zeroword;
            branch_offset_out <= `zeroword;
        end else if(!stall_in[2])begin
            op_out <= op_in;
            pc_out <= pc_in;
            rs1_value_out <= rs1_value_in;
            rs2_value_out <= rs2_value_in;
            rd_address_out <= rd_address_in;
            imm_out <= imm_in;
            branch_address_out <= branch_address_in;
            branch_offset_out <= branch_offset_in;
        end
    end
endmodule