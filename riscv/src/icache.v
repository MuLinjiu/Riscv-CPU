`include "Defines.v"
module ICACHE (
    input wire rst_in,
    input wire clk_in,

//from mc
    input wire inst_busy_in,
    input wire inst_enable_in,
    input wire[`regbus] inst_data_in,
//to mc
    output reg inst_read_out,
    output wire[`InstAddrBus] inst_address_out,

    //from if
    input wire inst_read_in,
    input wire[`InstAddrBus] inst_address_in,

    //to if
    output reg inst_enable_out,
    output reg[31:0] inst_data_out
);

reg[31:0] icache_data[`icachenum - 1 : 0];
reg[`icachetagbus] icache_tag[`icachenum - 1 : 0];
reg[`icachenum - 1 : 0] icache_valid;


//innitial

integer i;

initial begin
    for(i = 0 ; i < `icachenum ; i = i + 1)begin
        icache_valid <= 0;
    end
end

always @(*) begin
    if(rst_in == `rst_enable || !inst_read_in)begin
        inst_enable_out <= 1'b0;
        inst_read_out <= 1'b0;
        inst_data_out <= `zeroword;
    end else if(icache_tag[inst_address_in[`icachebus]] == inst_address_in[`tagbytes] && icache_valid[inst_address_in[`icachebus]])begin
        inst_enable_out <= 1'b1;
        inst_read_out <= 1'b0;
        inst_data_out <= icache_data[inst_address_in[`icachebus]];
    end else if(inst_enable_in == 1'b1)begin
        inst_enable_out <= 1'b1;
        inst_read_out <= 1'b0;
        inst_data_out <= inst_data_in;
    end else if(!inst_busy_in)begin
        inst_enable_out <= 1'b0;
        inst_read_out <= 1'b1;
        inst_data_out <= `zeroword;
    end else begin
        inst_enable_out <= 1'b0;
        inst_read_out <= 1'b0;
        inst_data_out <= `zeroword;
    end
end


always @(posedge clk_in) begin
    if(rst_in == `rst_enable)begin
        icache_valid <= 0;
    end else if(inst_enable_in == 1'b1)begin 
        icache_valid[inst_address_in[`icachebus]] <= 1'b1;
        icache_data[inst_address_in[`icachebus]] <= inst_address_in[`tagbytes];
        icache_tag[inst_address_in[`icachebus]] <= inst_data_in;
    end
end

    
endmodule