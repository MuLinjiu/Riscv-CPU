`include "Defines.v"
module EX (
    input wire rst,
    input wire[`InstAddrBus] pc_in,
    input wire[5:0] op_in,
    input wire[`regbus] imm_in,
    input wire[`regbus] rs1_value_in,
    input wire[`regbus] rs2_value_in,
    input wire[`regaddrbus] rd_address_in,
    input wire[`InstAddrBus] branch_address_in,
    input wire[`InstAddrBus] branch_offset_in,

    output reg Load_or_not,//to id


    output reg[5:0]op_out,

    output reg[2:0] status_out,//001 操作寄存器 010 内存写 011读内存 000初始化 100跳转 101jal|jalr


    output reg ex_forward_or_not,
    //output reg[2:0] width_out,
    output reg[`InstAddrBus] mem_address_out,
    output reg[`regbus] target_data_out,
    output reg[`regaddrbus] reg_address_out,

    output reg jump_or_not,
    output reg[`InstAddrBus] pc_jump_out
);
    
    always @(*) begin
        if(rst == `rst_enable)begin
            ex_forward_or_not = 1'b0;
            status_out = 3'b000;
            //width_out = 3'b000;
            mem_address_out = `zeroword;
            target_data_out = `zeroword;
            reg_address_out = 5'b00000;
            jump_or_not = 1'b0;
            pc_jump_out = `zeroword;
            Load_or_not = 1'b0;
            op_out = 6'b000000;
        end else begin
            
            status_out = 3'b001;//先所有的都操作寄存器
            ex_forward_or_not = 1'b0;
            //width_out = 3'b000;
            mem_address_out = `zeroword;
            target_data_out = `zeroword;
            reg_address_out = 5'b00000;
            jump_or_not = 1'b0;
            pc_jump_out = `zeroword;
            Load_or_not = 1'b0;
            op_out = op_in;
            case(op_in)
                `LB:begin
                    status_out = 3'b011;
                    Load_or_not = 1'b1;
                    mem_address_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `LH:begin
                    status_out = 3'b011;
                    Load_or_not = 1'b1;
                    mem_address_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `LW:begin
                    status_out = 3'b011;
                    Load_or_not = 1'b1;
                    mem_address_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `LBU:begin
                    status_out = 3'b011;
                    Load_or_not = 1'b1;
                    mem_address_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `LHU:begin
                    status_out = 3'b011;
                    Load_or_not = 1'b1;
                    mem_address_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `SB:begin
                    status_out = 3'b010;
                    mem_address_out = rs1_value_in + imm_in;
                    target_data_out = rs2_value_in;
                end
                `SH:begin
                    status_out = 3'b010;
                    mem_address_out = rs1_value_in + imm_in;
                    target_data_out = rs2_value_in;
                end
                `SW:begin
                    status_out = 3'b010;
                    mem_address_out = rs1_value_in + imm_in;
                    target_data_out = rs2_value_in;
                end
                `ADD:begin
                    target_data_out = rs1_value_in + rs2_value_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `ADDI:begin
                    target_data_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SUB:begin
                    target_data_out = rs1_value_in - rs2_value_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `LUI:begin
                    target_data_out = imm_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `AUIPC:begin
                    target_data_out = imm_in + pc_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `XOR:begin
                    target_data_out = rs1_value_in ^ rs2_value_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `XORI:begin
                    target_data_out = rs1_value_in + imm_in;
                    reg_address_out = rd_address_in;
                end
                `OR:begin
                    target_data_out = rs1_value_in | rs2_value_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `ORI:begin
                    target_data_out = rs1_value_in | imm_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `AND:begin
                    target_data_out = rs1_value_in & rs2_value_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `ANDI:begin
                    target_data_out = rs1_value_in & imm_in;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLL:begin
                    target_data_out = rs1_value_in << rs2_value_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLLI:begin
                    target_data_out = rs1_value_in << imm_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SRL:begin
                    target_data_out = rs1_value_in >> rs2_value_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SRLI:begin
                    target_data_out = rs1_value_in >> imm_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SRA:begin
                    target_data_out = rs1_value_in >>> rs2_value_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SRAI:begin
                    target_data_out = rs1_value_in >>> imm_in[4:0];
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLT:begin
                    target_data_out = ($signed (rs1_value_in) < $signed (rs2_value_in)) ? 1'b1 : 1'b0;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLTI:begin
                    target_data_out = ($signed (rs1_value_in) < $signed (imm_in)) ? 1'b1 : 1'b0;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLTU:begin
                    target_data_out = ( (rs1_value_in) <  (rs2_value_in)) ? 1'b1 : 1'b0;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `SLTIU:begin
                    target_data_out = ( (rs1_value_in) <  (imm_in)) ? 1'b1 : 1'b0;
                    reg_address_out = rd_address_in;
                    ex_forward_or_not = 1'b1;
                end
                `BEQ:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = (rs1_value_in == rs2_value_in) ? 1'b1 : 1'b0;
                end
                `BNE:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = (rs1_value_in != rs2_value_in) ? 1'b1 : 1'b0;
                end
                `BLT:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = ($signed (rs1_value_in) < $signed (rs2_value_in)) ? 1'b1 : 1'b0;
                end
                `BGE:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = ($signed (rs1_value_in) >= $signed (rs2_value_in)) ? 1'b1 : 1'b0;
                end
                `BLTU:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = ( (rs1_value_in) <  (rs2_value_in)) ? 1'b1 : 1'b0;
                end
                `BGEU:begin
                    status_out = 3'b100;
                    pc_jump_out = branch_address_in + branch_offset_in;
                    jump_or_not = ( (rs1_value_in) >=  (rs2_value_in)) ? 1'b1 : 1'b0;
                end
                `JAL:begin
                    status_out = 3'b101;
                    target_data_out = pc_in + 4;
                    reg_address_out = rd_address_in;
                    jump_or_not = 1'b1;
                    pc_jump_out = branch_address_in + branch_offset_in;
                end
                `JALR:begin
                    status_out = 3'b101;
                    target_data_out = pc_in + 4;
                    reg_address_out = rd_address_in;
                    jump_or_not = 1'b1;
                    pc_jump_out = branch_address_in + branch_offset_in;
                end
            endcase
        end
    end
endmodule