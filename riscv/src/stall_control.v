`include "Defines.v"
module stall_control (
    input wire clk,
    input wire rst,
    input wire stall_from_if,
    input wire stall_from_id,
    input wire stall_from_mem,

    output reg[4:0] stall_out
);
    always @(*) begin
        if(rst == `rst_enable)begin
            stall_out <= 5'b00000;
        end else begin
            if(stall_from_mem == 1'b1)begin//顺序要反过来
                stall_out <= 5'b11111;
            end else if(stall_from_id == 1'b1)begin
                stall_out <= 5'b00111;
            end else if(stall_from_if == 1'b1)begin
                stall_out <= 5'b00011;
            end
        end
    end
endmodule