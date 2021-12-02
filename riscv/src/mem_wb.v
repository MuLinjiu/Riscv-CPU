`include "Defines.v"

module MEM_WB (
    input wire clk,
    input wire rst,

    input wire[`stallbus] stall_in,

    input wire if_operate_reg_in,
    input wire[`regaddrbus] rd_address_in,
    input wire[`regbus] rd_value_in,

    output reg if_operate_reg_out,
    output reg[`regaddrbus] rd_address_out,
    output reg [`regbus] rd_value_out
);

always @(posedge clk) begin
    if(rst == `rst_enable || stall_in[4])begin
        if_operate_reg_out <= 1'b0;
        rd_address_out <= `Nopreg;
        rd_value_out <= `zeroword;
    end else if(!stall_in[4])begin
        if_operate_reg_out <= if_operate_reg_in;
        rd_address_out <= rd_address_in;
        rd_value_out <= rd_value_in;
    end
end
    
endmodule