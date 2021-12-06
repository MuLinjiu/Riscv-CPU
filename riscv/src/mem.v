`include "Defines.v"
module MEM (
    input wire rst,

    input wire[5:0] op_in,
    input wire[2:0] status_in,//001 操作寄存器 010 内存写 011读内存 000初始化 100跳转 101jal|jalr
    input wire[`InstAddrBus] mem_address_in,
    input wire[`regbus] target_data_in,
    input wire[`regaddrbus] reg_address_in,
    
    //from mc
    input wire mc_mem_busy_in,
    input wire mc_inst_busy_in,
    input wire mc_enable_in,
    input wire[`regbus] mc_mem_data_in,

    //to mc
    output reg mc_read_or_write_out,
    output reg mc_mem_enable_out,
    output reg[2:0] mc_width_out,
    output reg[`regbus] mc_target_data_out,
    output reg[`regbus] mc_mem_address_out,

    //to mem_wb
    output reg if_operate_reg_out,
    output reg[`regbus] rd_value_out,
    output reg[`regaddrbus] rd_address_out,


//stall_ct
    output reg mem_stall_out

);

always @(*) begin
        mc_read_or_write_out = 1'b0;
        mc_mem_enable_out = 1'b0;
        mc_target_data_out = `zeroword;
        mc_mem_address_out = `zeroword;
        //if_operate_reg_out = 1'b1;
        rd_value_out = target_data_in;
        rd_address_out = reg_address_in;
        mc_width_out = 0;  
        mem_stall_out = 1'b0;//忘了 , 焯！
    if(rst == `rst_enable)begin
        mc_mem_enable_out = 1'b0;
        mc_target_data_out = `zeroword;
        mc_mem_address_out = `zeroword;
        if_operate_reg_out = 1'b0;
        rd_value_out = `zeroword;
        rd_address_out = `Nopreg;
    end else begin
        // if(status_in == 3'b010)begin
        //     if_operate_reg_out = 1'b1;
        // end
        if(status_in != 3'b000 && status_in != 3'b010 && status_in != 3'b100)begin
            if_operate_reg_out = 1'b1;
        end 
        else begin
            if_operate_reg_out = 1'b0;
        end
        if(mc_enable_in)begin
            if(op_in == `LW)begin
                rd_value_out = mc_mem_data_in;
                rd_address_out = reg_address_in;
            end else if(op_in == `LHU)begin
                rd_value_out = {16'b0,mc_mem_data_in[15:0]};
                rd_address_out = reg_address_in;
            end else if(op_in == `LH)begin
                rd_value_out = {{16{mc_mem_data_in[15]}},mc_mem_data_in[15:0]};
                //if_operate_reg_out = 1'b1;
                rd_address_out = reg_address_in;
            end else if(op_in == `LB)begin
                rd_value_out = {{24{mc_mem_data_in[7]}},mc_mem_data_in[7:0]};
                //if_operate_reg_out = 1'b1;
                rd_address_out = reg_address_in;
                
            end else if(op_in == `LBU)begin
                rd_value_out = {16'b0,mc_mem_data_in[7:0]};
                //if_operate_reg_out = 1'b1;
                rd_address_out = reg_address_in;
            end 
        end else begin
            if(op_in == `LW)begin
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_width_out = 3'b100;
                end
            end else if(op_in == `LHU)begin
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_width_out = 3'b010;
                end
            end else if(op_in == `LH)begin
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_width_out = 3'b010;
                end
            end else if(op_in == `LB)begin
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_width_out = 3'b001;
                end
            end else if(op_in == `LBU)begin
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_width_out = 3'b001;
                end
            end else if(op_in == `SW)begin
                if_operate_reg_out = 1'b0;
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_read_or_write_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_target_data_out = target_data_in;
                    mc_width_out = 3'b100;
                end
            end else if(op_in == `SH)begin
                if_operate_reg_out = 1'b0;
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_read_or_write_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_target_data_out = target_data_in[15:0];
                    mc_width_out = 3'b010;
                end
            end else if(op_in == `SB)begin
                if_operate_reg_out = 1'b0;
                mem_stall_out = 1'b1;
                if(!mc_mem_busy_in)begin
                    mc_mem_enable_out = 1'b1;
                    mc_read_or_write_out = 1'b1;
                    mc_mem_address_out = mem_address_in;
                    mc_target_data_out = target_data_in[7:0];
                    mc_width_out = 3'b001;
                end
            end
        end
    end 
    
end


    
endmodule