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
    output wire ram_wr,//1 for write,0 for read

    input wire hci_if_full
);

wire[`InstAddrBus] address;

reg[7:0] ldata[3:0];
wire[7:0] sdata[3:0];

reg[2:0] status;
wire[2:0] number;
reg[1:0] hci_status;

assign sdata[0] = mem_target_data_in[7:0];
assign sdata[1] = mem_target_data_in[15:8];
assign sdata[2] = mem_target_data_in[23:16];
assign sdata[3] = mem_target_data_in[31:24];




reg[31:0] dcache_data[`icachenum - 1 : 0];
reg[`icachetagbus] dcache_tag[`icachenum - 1 : 0];
reg[`icachenum - 1 : 0] dcache_valid;

integer i;

initial begin
    for(i = 0 ; i < `icachenum ; i = i + 1)begin
        dcache_valid[i] <= 0;
        end
end




assign number = mem_enable_in == 1'b1 ? mem_width_in : (inst_enable_in == 1'b1 ? 4 : 0);
assign address = mem_enable_in == 1'b1 ? mem_address_in : inst_address_in;

// RAM

assign ram_data_out = status == 3'b100 ? `zeroword : sdata[status];
assign ram_address_out = address + status;      
assign ram_wr = mem_enable_in == 1'b1 ? (status == number ? 1'b0 : mem_read_or_write_in ) : 1'b0;




always @(posedge clk_in) begin
    if(rst_in == `rst_enable || (jump_or_not_in && !mem_enable_in))begin
        hci_status <= 2'b11;
        status <= 0;
        inst_busy_out <= 1'b0;
        mem_busy_out <= 1'b0;
        inst_enable_out <= 1'b0;
        mem_enable_out <= 1'b0;
        ldata[0] <= 0;
        ldata[1] <= 0;
        ldata[2] <= 0;
        ldata[3] <= 0;
    end else if(number && !ram_wr)begin//read

        if(dcache_tag[mem_address_in[`icachebus]] == mem_address_in[`tagbytes] && dcache_valid[mem_address_in[`icachebus]])begin
            inst_data_out <= dcache_data[mem_address_in[`icachebus]];
        end
        if(status == 0)begin
            mem_enable_out <= 1'b0;
            inst_enable_out <= 1'b0;
            status <= status + 1;
            mem_busy_out <= !mem_enable_in;
            inst_busy_out <= mem_enable_in;
        end else if(status < number)begin
            ldata[status - 1] <= ram_data_in;
            status <= status + 1;
        end else begin
            if(mem_enable_in == 1'b1)begin
                mem_enable_out <= 1'b1;
                case(mem_width_in)
                3'b001:mem_rdata_out <= ram_data_in;
                3'b010:mem_rdata_out <= {ram_data_in,ldata[0]};
                3'b100:mem_rdata_out <= {ram_data_in,ldata[2],ldata[1],ldata[0]};
                endcase
            end else begin
                inst_data_out <= {ram_data_in,ldata[2],ldata[1],ldata[0]};
                inst_enable_out <= 1'b1;
            end
            status <= 0;
        end
    end else if(number && ram_wr)begin//write
        if(mem_address_in[17:16] != 2'b11)begin
            dcache_valid[mem_address_in[`icachebus]] <= 1'b1;
            dcache_tag[mem_address_in[`icachebus]] <= mem_address_in[`tagbytes];
            dcache_data[mem_address_in[`icachebus]] <= mem_target_data_in;
            if(status == 0)begin
                inst_busy_out <= 1'b1;
                inst_enable_out <= 1'b0;
                mem_busy_out <= 1'b0;
                mem_enable_out <= 1'b0;
            end 
            if(status == number - 1)begin//??????else ?????????number = 1???status = 0
                mem_enable_out <= 1'b1;
                status <= 0;
            end else begin
                status <= status + 1;
            end
        end else begin
            if(hci_status != 2'b00)begin
                hci_status <= hci_status - 1;
            end else begin
                if(hci_if_full == 1'b0)begin
                    if(status == 0)begin
                        inst_busy_out <= 1'b1;
                        inst_enable_out <= 1'b0;
                        mem_busy_out <= 1'b0;
                        mem_enable_out <= 1'b0;
                    end 
                    if(status == number - 1)begin//??????else ?????????number = 1???status = 0
                        mem_enable_out <= 1'b1;
                        status <= 0;
                    end else begin
                        status <= status + 1;
                    end
                    hci_status <= 2'b11;
                end
            end
        end
    end else begin
        mem_busy_out <= 1'b0;
        mem_enable_out <= 1'b0;
        inst_busy_out <= 1'b0;
        inst_enable_out <= 1'b0;
    end
end
    
endmodule