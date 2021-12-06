`include "Defines.v"
`timescale 1ns/1ps
module ID (
    input wire rst,
    input wire[`InstAddrBus] pc_in,
    input wire[`InstBus] inst_in,
    input wire Load_or_not,//stall,EX to id;
    output reg id_stall_out,
//to register 
    output reg rs1_read_out,//0/1,0rst
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
    output reg[5:0] op_out,
    // output reg[`Func3Bus] func3_out,
    // output reg[`Func7Bus] func7_out,

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
        if(rst == `rst_enable)begin

            rs1_read_out = 1'b0;
            rs2_read_out = 1'b0;
            rs1_addr_out = `zeroword;
            rs2_addr_out = `zeroword;
            pc_out = `zeroword;
            op_out = 6'b000000;
            // func3_out = 0;
            // func7_out = 0;
            rd_address_out = `zeroword;
            imm_out = `zeroword;
            if_operate_reg_out = 1'b0;
            branch_address_out = `zeroword;
            branch_offset_out = `zeroword;
        end else begin
            rs1_read_out = 1'b0;
            rs2_read_out = 1'b0;
            rs1_addr_out = inst_in[19:15];//
            rs2_addr_out = inst_in[24:20];//
            pc_out = pc_in;//
            op_out = `OP_NON;
            // func3_out = 0;
            // func7_out = 0;
            rd_address_out = inst_in[11:7];//
            imm_out = `zeroword;
            if_operate_reg_out = 1'b0;
            branch_address_out = `zeroword;
            branch_offset_out = `zeroword;
            case(op)
                `opLUI : begin
                    if_operate_reg_out = 1'b1;
                    imm_out = {inst_in[31:12],12'b0};
                    rd_address_out = inst_in[11:7];
                    op_out = `LUI;
                end
                `opAUIPC:begin
                    if_operate_reg_out = 1'b1;
                    imm_out = {inst_in[31:12],12'b0};
                    rd_address_out = inst_in[11:7];
                    op_out = `AUIPC;
                end
                `opJAL:begin
                    imm_out = {{12{inst_in[31]}},inst_in[19:12],inst_in[20],inst_in[30:25],inst_in[24:21],1'b0};
                    rd_address_out = inst_in[11:7];
                    if_operate_reg_out = 1'b1;
                    op_out = `JAL;
                    branch_address_out = pc_in;
                    branch_offset_out = {{12{inst_in[31]}},inst_in[19:12],inst_in[20],inst_in[30:25],inst_in[24:21],1'b0};
                end
                `opJALR:begin
                    imm_out = {{21{inst_in[31]}}, inst_in[30:20]};
                    if_operate_reg_out = 1'b1;
                    rs1_read_out = 1'b1;
                    op_out = `JALR;
                    branch_address_out = rs1_value_out;
                    branch_offset_out = {{21{inst_in[31]}}, inst_in[30:20]};
                end
                `opBranch:begin
                    imm_out = {{20{inst_in[31]}},inst_in[7],inst_in[30:25],inst_in[11:8],1'b0};
                    rs1_read_out = 1'b1;
                    rs2_read_out = 1'b1;
                    branch_address_out = pc_in;
                    branch_offset_out = {{20{inst_in[31]}},inst_in[7],inst_in[30:25],inst_in[11:8],1'b0};
                    case(func3)
                        3'b000:begin
                            op_out = `BEQ;
                        end
                        3'b001:begin
                            op_out = `BNE;
                        end
                        3'b100:begin
                            op_out = `BLT;
                        end
                        3'b101:begin
                            op_out = `BGE;
                        end
                        3'b110:begin
                            op_out = `BLTU;
                        end
                        3'b111:begin
                            op_out = `BGEU;
                        end
                    endcase
                end
                `opLoad:begin
                    imm_out = {{21{inst_in[31]}}, inst_in[30:20]};
                    if_operate_reg_out = 1'b1;
                    rs1_read_out = 1'b1;
                    case(func3)
                        3'b000:begin
                            op_out = `LB;
                        end
                        3'b001:begin
                            op_out = `LH;
                        end
                        3'b010:begin
                            op_out = `LW;
                        end
                        3'b100:begin
                            op_out = `LBU;
                        end
                        3'b101:begin
                            op_out = `LHU;
                        end
                    endcase
                end
                `opStore:begin
                    imm_out = {{21{inst_in[31]}}, inst_in[30:25], inst_in[11:7]};
                    rs1_read_out = 1'b1;
                    rs2_read_out = 1'b1;
                    case(func3)
                        3'b000:begin
                            op_out = `SB;
                        end
                        3'b001:begin
                            op_out = `SH;
                        end
                        3'b010:begin
                            op_out = `SW;
                        end
                    endcase
                end
                `opI:begin
                    if_operate_reg_out = 1'b1;
                    imm_out = {{21{inst_in[31]}}, inst_in[30:20]};
                    rs1_read_out = 1'b1;
                    case(func3)
                        3'b000:begin
                            op_out = `ADDI;
                        end
                        3'b010:begin
                            op_out = `SLTI;
                        end
                        3'b011:begin
                            op_out = `SLTIU;
                        end
                        3'b100:begin
                            op_out = `XORI;
                        end
                        3'b110:begin
                            op_out = `ORI;
                        end
                        3'b111:begin
                            op_out = `ANDI;
                        end
                        3'b001:begin
                            op_out = `SLLI;
                            imm_out = {27'd0,inst_in[24:20]};
                        end
                        3'b101:begin
                            imm_out = {27'd0,inst_in[24:20]};
                            if(func7 == 7'b0000000)begin
                                op_out = `SRLI;
                            end else if(func7 == 7'b0100000)begin
                                op_out = `SRAI;
                            end
                        end
                    endcase
                end
                `opR:begin
                    if_operate_reg_out = 1'b1;
                    rs1_read_out = 1'b1;
                    rs2_read_out = 1'b1;
                    case(func3)
                        3'b000:begin
                            if(func7 == 7'b0000000)begin
                                op_out = `ADD;
                            end else if(func7 == 7'b0100000)begin
                                op_out = `SUB;
                            end   
                        end
                        3'b001:begin
                            op_out = `SLL;
                        end
                        3'b010:begin
                            op_out = `SLT;
                        end
                        3'b011:begin
                            op_out = `SLTU;
                        end
                        3'b100:begin
                            op_out = `XOR;
                        end
                        3'b101:begin
                            if(func7 == 7'b0000000)begin
                                op_out = `SRL;
                            end else if(func7 == 7'b0100000)begin
                                op_out = `SRA;
                            end
                        end
                        3'b110:begin
                            op_out = `OR;
                        end
                        3'b111:begin
                            op_out = `AND;
                        end
                    endcase
                end
            endcase
            //$display($time," pc : %h , imm : %h , inst : %b ",pc_in,imm_out,inst_in);
        end
    end


    //rs1 rs2获取，register或前传；

    always @(*) begin
        id_stall_out = 1'b0;
        if(rst == `rst_enable)begin
            rs1_value_out = `zeroword;
        end else if(Load_or_not == 1'b1 && ex_forward_or_not == 1'b1 && rs1_addr_out == ex_forward_address)begin
            rs1_value_out = `zeroword;
            id_stall_out = 1'b1;//structure hazard
        end else if(rs1_read_out == 1'b1 && ex_forward_or_not == 1'b1 && rs1_addr_out == ex_forward_address)begin
            rs1_value_out = ex_forward_value;
        end else if(rs1_read_out == 1'b1 && MEM_forward_or_not == 1'b1 && rs1_addr_out == MEM_forward_address)begin
            rs1_value_out = MEM_forward_value;
        end else if(rs1_read_out == 1'b1) begin
            rs1_value_out = rs1_value_in;
        end else begin
            rs1_value_out = `zeroword;
        end
    end
always @(*) begin
        id_stall_out = 1'b0;
        if(rst == `rst_enable)begin
            rs2_value_out = `zeroword;
        end else if(Load_or_not == 1'b1 && ex_forward_or_not == 1'b1 && rs2_addr_out == ex_forward_address)begin
            rs2_value_out = `zeroword;
            id_stall_out = 1'b1;//structure hazard
        end else if(rs2_read_out == 1'b1 && ex_forward_or_not == 1'b1 && rs2_addr_out == ex_forward_address)begin
            rs2_value_out = ex_forward_value;
        end else if(rs2_read_out == 1'b1 && MEM_forward_or_not == 1'b1 && rs2_addr_out == MEM_forward_address)begin
            rs2_value_out = MEM_forward_value;
        end else if(rs2_read_out == 1'b1) begin
            rs2_value_out = rs2_value_in;
        end else begin
            rs2_value_out = `zeroword;
        end
    end

    
endmodule