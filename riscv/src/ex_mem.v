`include "Defines.v"

module EX_MEM (
    input wire rst,
    input wire clk,

    input wire[`stallbus] stall_in,

    input wire[5:0] op_in,
    input wire status_in,
    input wire[`InstAddrBus] mem_address_in,
    input wire[`regbus] target_data_in,
    input wire[`regaddrbus] reg_address_in,


    output reg[5:0] op_out,
    output reg status_out,
    output reg[`InstAddrBus] mem_address_out,
    output reg[`regbus] target_data_out,
    output reg[`regaddrbus] reg_address_out
);
    always @(posedge clk) begin
        if(rst == `rst_enable)begin
            op_out <= 6'b000000;
            status_out <= 3'b000;
            mem_address_out <= `zeroword;
            target_data_out <= `zeroword;
            reg_address_out <= `Nopreg;
        end else if(!stall_in[3]) begin
            op_out <= op_in;
            status_out <= status_in;
            mem_address_out <= mem_address_in;
            target_data_out <= target_data_in;
            reg_address_out <= reg_address_in;
        end
    end
endmodule