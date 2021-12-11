`include "Defines.v"
module IF (
    input wire rst,

    input wire[`stallbus] stall_in,

    //from pc_reg
    input wire[`InstAddrBus] pc_in,
    input wire pc_enable_in,

    //to if_id
    output reg[`InstAddrBus] pc_out,
    output reg[`InstBus] inst_out,

    //from icache
    input wire mc_inst_enable_in,
    input wire[`InstBus] mc_inst_value_in, 

    //to icache 
    output reg mc_inst_enable_out,
    output reg[`InstBus] mc_inst_add_out,
//to_stall_control
    output wire stall_or_not
);
assign stall_or_not = pc_enable_in && !mc_inst_enable_in;//pc传进来mc未处理完
always @(*) begin

    //处理to icache部分以及pc
    if(rst || !pc_enable_in)begin
        pc_out = `zeroword;
        mc_inst_add_out = `zeroword;
        mc_inst_enable_out = 1'b0;
    end else begin
        pc_out = pc_in;
        mc_inst_add_out = pc_in;
        mc_inst_enable_out = 1'b1;
    end
//inst_out
    if(mc_inst_enable_in && !rst)begin
        inst_out = mc_inst_value_in;
    end else begin
        inst_out = `zeroword;
    end
end


    
endmodule