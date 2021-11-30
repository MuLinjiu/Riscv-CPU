`include "Defines.v"

module IF_ID (
    input wire[`InstAddrBus] pc_in_from_if,
    input wire[`InstBus] inst_in_from_if,

    output reg[`InstAddrBus] pc_out_to_id,
    output reg[`InstBus] inst_out_to_id,

    input wire rst,
    input wire clk,

    input wire[4:0] stall_in,
    input wire jump_or_not
);

always @(posedge clk) begin
    if(rst == `rst_enable || jump_or_not || (stall_in[1] && !stall_in[2]))begin
        //id stop ex not stop
        pc_out_to_id <= `zeroword;
        inst_out_to_id <= `zeroword;
    end else if(!stall_in[1])begin
        pc_out_to_id <= pc_in_from_if;
        inst_out_to_id <= inst_in_from_if;
    end
end
    
endmodule