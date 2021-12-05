// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "Defines.v"
module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

// always @(posedge clk_in)
//   begin
//     if (rst_in)
//       begin
      
//       end
//     else if (!rdy_in)
//       begin
      
//       end
//     else
//       begin
      
//       end
//   end

//stall control
wire rst = rst_in || !rdy_in;
wire stall_if;
wire stall_id;
wire stall_mem;

wire[`stallbus] stall_status;

wire[`InstAddrBus] pc;
wire[`InstAddrBus] pc_jump;

//pc_reg to if
wire pc_enable;

//mem_ctrl to icache
wire mc_inst_enable;
wire[`regbus] mc_inst_data;

//icache to mem_ctrl
wire icache_inst_read_out;
wire[`InstAddrBus] icache_inst_address_out;

//icache to if
wire icache_inst_enable_out;
wire[`regbus] icache_inst_data_out;

//if to icache
wire mc_inst_enable_out;
wire[`InstAddrBus] mc_inst_address_out;

//if to if_id




endmodule