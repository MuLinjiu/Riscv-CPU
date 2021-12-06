`include "Defines.v"
`timescale 1ns/1ps
module pc_reg (
    input wire clk,
    input wire rst,

    input wire[4:0] stall_in,

    input wire jump_or_not,
    input wire[`InstAddrBus] pc_in,
    output reg[`InstAddrBus] pc_out,

    output reg pc_enable
);
    
    reg[`InstAddrBus] pc_store;//分支预测或其余情况暂存pc

    always @(posedge clk) begin
        
        if(rst == `rst_enable) begin
            pc_store <= 1'b0;
            pc_enable <= 1'b0;
        end else begin
            pc_enable <= 1'b1;
            if(jump_or_not)begin
                pc_store <= pc_in + 4;
                pc_out <= pc_in;
                 //$display($time," pc_jump : %h",pc_in);
            end else if(!stall_in[0])begin
                pc_store <= pc_store + 4;
                pc_out <= pc_store;
                 //$display($time," pc_normal : %h",pc_store);
            end
        end
    end

endmodule