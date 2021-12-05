`include "Defines.v"
module memory_control (
    input wire clk_in,
    input wire rst_in,
    input wire jump_or_not_in,
//from mem
    input wire mem_read_or_write_in,
    input wire mem_enable_in,
    input wire[2:0] mem_width_in,
    input wire[`regbus] mem_target_data_in,
    input wire[`regbus] mem_address_in, 

//to mem
    output reg mem_enable_out,
    output reg[`regbus] mem_rdata_out,
    output reg mem_busy_out,

    //from icache
    input wire inst_enable_in,
    input wire[`InstAddrBus] inst_address_in,


    //to icache
    output reg[`regbus] inst_data_out,
    output reg inst_enable_out,
    output reg inst_busy_out,


    //from RAM
    input wire[7:0] ram_data_in,

    //to RAM
    output wire[7:0] ram_data_out,
    output wire[31:0] ram_address_out,
    output wire ram_wr//1 for write,0 for read
);

wire[`InstAddrBus] address;

reg[7:0] ldata[3:0];
wire[7:0] sdata[3:0];

reg[2:0] status;
wire[2:0] number;

assign sdata[0] = mem_target_data_in[7:0];
assign sdata[1] = mem_target_data_in[15:8];
assign sdata[2] = mem_target_data_in[23:16];
assign sdata[3] = mem_target_data_in[31:24];


assign number = mem_enable_in == 1'b1 ? mem_width_in : (inst_enable_in == 1'b1 ? 4 : 0);
assign address = mem_enable_in == 1'b1 ? mem_address_in : inst_address_in;

// RAM

assign ram_data_out = status == 3'b100 ? `zeroword : sdata[status];
assign ram_address_out = address + status;
assign ram_wr = mem_enable_in == 1'b1 ? (status == number ? 1'b0 : mem_read_or_write_in ) : 1'b0;




always @(posedge clk_in) begin
    if(rst_in == `rst_enable || (jump_or_not_in && !mem_enable_in))begin
        status <= 0;
        inst_busy_out <= 1'b0;
        mem_busy_out <= 1'b0;
        inst_enable_out <= 1'b0;
        mem_enable_out <= 1'b0;
        ldata[0] <= 0;
        ldata[1] <= 0;
        ldata[2] <= 0;
        ldata[3] <= 0;
    end else if(number && !ram_wr)begin
        if(status == 0)begin
            mem_enable_out <= 1'b0;
            inst_enable_out <= 1'b0;
            status <= status + 1;
            mem_busy_out <= !mem_enable_in;
            inst_busy_out <= mem_enable_in;
        end else if(status < number)begin
            ldata[status] <= ram_data_in;
            status <= status + 1;
        end else begin
            status <= 0;
            if(mem_enable_in == 1'b1)begin
                mem_enable_out <= 1'b1;
                case(mem_width_in)
                3'b001:mem_rdata_out <= ram_data_in;
                3'b010:mem_rdata_out <= {ram_data_in,ldata[0]};
                3'b100:mem_rdata_out <= {ram_data_in,ldata[2],ldata[1],ldata[0]};
                endcase
            end else begin
                inst_enable_out <= 1'b1;
                inst_data_out <= {ram_data_in,ldata[2],ldata[1],ldata[0]};
            end
        end
    end else if(number &&ram_wr)begin
        if(status == 0)begin
            inst_busy_out <= 1'b1;
            inst_enable_out <= 1'b0;
            mem_busy_out <= 1'b0;
            mem_enable_out <= 1'b0;
        end else if(status > 0 && status < number - 1)begin
            status = status + 1;
        end else begin
            mem_enable_out <= 1'b1;
            status <= 0;
        end
    end else begin
        mem_busy_out <= 1'b0;
        mem_enable_out <= 1'b0;
        inst_busy_out <= 1'b0;
        inst_enable_out <= 1'b0;
    end
end
    
endmodule