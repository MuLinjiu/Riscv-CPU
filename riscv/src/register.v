`include "Defines.v"

module register (
    input wire clk,
    input wire rst,

    //write
    input wire write_enable,
    input wire[`regaddrbus] write_address,
    input wire [`regbus] write_value,
    //read
    input wire read_enable1,
    input wire[`regaddrbus] rs1_address,
    output reg[`regbus] rs1_value,

    input wire read_enable2,
    input wire[`regaddrbus] rs2_address,
    output reg[`regbus] rs2_value

);
    reg[`regbus]    regs[0:`regnum - 1];

    //write 需要上升沿写入
    always @(posedge clk) begin
        if(rst == `rst_disable)begin
            if((write_enable == `write_enable) && write_address != 5'h0)begin
                regs[write_address] <= write_value;
            end
        end
    end
    //read 不需要时序电路
    always @(*) begin
        if(rst == `rst_enable)begin
            rs1_value <= `zeroword;
        end else if (rs1_address == `zeroreg)begin//reg[0]
            rs1_value <= `zeroword;
        end else if((rs1_address == write_address) && (read_enable1 == `read_enable) && (write_enable == `write_enable))begin
            rs1_value <= write_value;
        end else if(read_enable1 == `read_enable) begin
            rs1_value <= regs[rs1_address];
        end else begin
            rs1_value <= `zeroword;
        end
    end

always @(*) begin
        if(rst == `rst_enable)begin
            rs2_value <= `zeroword;
        end else if (rs2_address == `zeroreg)begin//reg[0]
            rs2_value <= `zeroword;
        end else if((rs2_address == write_address) && (read_enable2 == `read_enable) && (write_enable == `write_enable))begin
            rs2_value <= write_value;
        end else if(read_enable2 == `read_enable) begin
            rs2_value <= regs[rs2_address];
        end else begin
            rs2_value <= `zeroword;
        end
    end

endmodule