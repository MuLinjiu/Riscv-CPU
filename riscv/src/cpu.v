// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "Defines.v"
// `include "stall_control.v"
// `include "pc_reg.v"
// `include "icache.v"
// `include "register.v"
// `include "if.v"
// `include "if_id.v"
// `include "id.v"
// `include "id_ex.v"
// `include "ex.v"
// `include "ex_mem.v"
// `include "mem.v"
// `include "mem_wb.v"
// `include "memory_control.v"
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
assign dbgreg_dout = rst_in || !rdy_in;
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
wire[`InstAddrBus]  if_pc;
wire if_inst_enable;
wire[`InstBus] if_inst;

wire mc_mem_busy;
wire mc_inst_busy;

//if_id to id
wire[`InstAddrBus] id_pc_in;
wire[`InstBus] id_inst_in;

//register to id
wire[`regbus] rs1_value;
wire[`regbus] rs2_value;

// id to register
wire rs1_read;
wire rs2_read;
wire[`regaddrbus] rs1_address;
wire[`regaddrbus] rs2_address;

//ex to id
wire load_or_not;

// id to id_ex

wire[`regbus] id_ex_rs1_value;
wire[`regbus] id_ex_rs2_value;
wire[`regaddrbus] id_ex_rd_address;
wire[`regbus] id_ex_imm;
wire[`regbus] id_ex_branch_address;
wire[`regbus] id_ex_branch_offset_in;
wire[5:0] id_ex_op;
wire[`InstAddrBus] id_ex_pc;
wire id_ex_if_operate_reg;
//
wire ex_jump;
wire if_jump = ex_jump && !stall_status[3];
//id_ex to ex
wire[`regbus] ex_rs1_value;
wire[`regbus] ex_rs2_value;
wire[`regaddrbus] ex_rd_address;
wire[`regbus] ex_imm;
wire[`regbus] ex_branch_address;
wire[`regbus] ex_branch_offset_in;
wire[5:0] ex_op;
wire[`InstAddrBus] ex_pc;

//ex to ex_mem
wire[5:0] ex_mem_op;
wire[2:0] ex_mem_status;
wire[`InstAddrBus] ex_mem_MEM_address;
wire[`regbus] ex_mem_target_data_in;
wire[`regaddrbus] ex_mem_reg_address;
wire ex_forward_or_not;

//ex_mem to mem
wire[5:0] mem_op;
wire[2:0] mem_status;
wire[`InstAddrBus] mem_MEM_address;
wire[`regbus] mem_target_data_in;
wire[`regaddrbus] mem_reg_address;

//mem to memory_control
wire mem_mc_read_or_write;
wire mem_mc_enable;
wire[2:0] mem_mc_width;
wire[`regbus] mem_mc_target_data;
wire[`regbus] mem_mc_address;

//memory_control to mem
wire mc_to_mem_enable;
wire[`regbus] mc_mem_data;

//mem to mem_wb
wire mem_wb_if_operate_reg;
wire[`regaddrbus] mem_wb_rd_address;
wire[`regbus] mem_wb_rd_value;

//mem_wb to register
wire wb_if_operate_reg;
wire[`regaddrbus] wb_rd_address;
wire[`regbus] wb_rd_value;


stall_control stall_control0(
  .clk(clk_in),
  .rst(rst),
  .stall_from_if(stall_if),
  .stall_from_id(stall_id),
  .stall_from_mem(stall_mem),
  
  .stall_out(stall_status)
);


ICACHE icache0(
  .rst_in(rst),
  .clk_in(clk_in),
  .inst_busy_in(mc_inst_busy),
  .inst_enable_in(mc_inst_enable),
  .inst_data_in(mc_inst_data),

  .inst_read_in(mc_inst_enable_out),
  .inst_address_in(mc_inst_address_out),

  .inst_read_out(icache_inst_read_out),
  .inst_address_out(icache_inst_address_out),

  .inst_enable_out(icache_inst_enable_out),
  .inst_data_out(icache_inst_data_out)

);

pc_reg pc_reg0(
  .clk(clk_in),
  .rst(rst),
  .stall_in(stall_status),

  .jump_or_not(if_jump),
  .pc_in(pc_jump),
  .pc_out(pc),

  .pc_enable(pc_enable)
);

register register0(
  .clk(clk_in),
  .rst(rst),

  .write_enable(wb_if_operate_reg),
  .write_address(wb_rd_address),
  .write_value(wb_rd_value),

  .read_enable1(rs1_read),
  .read_enable2(rs2_read),
  .rs1_address(rs1_address),
  .rs2_address(rs2_address),

  .rs1_value(rs1_value),
  .rs2_value(rs2_value)
);


IF if0(
  .rst(rst),

  .stall_in(stall_status),

  .pc_in(pc),
  .pc_enable_in(pc_enable),

  .pc_out(if_pc),
  .inst_out(if_inst),

  .mc_inst_enable_in(icache_inst_enable_out),
  .mc_inst_value_in(icache_inst_data_out),

  .mc_inst_enable_out(mc_inst_enable_out),
  .mc_inst_add_out(mc_inst_address_out),

  .stall_or_not(stall_if)
);


IF_ID if_if0(
  .pc_in_from_if(if_pc),
  .inst_in_from_if(if_inst),

  .pc_out_to_id(id_pc_in),
  .inst_out_to_id(id_inst_in),

  .rst(rst),
  .clk(clk_in),

  .stall_in(stall_status),
  .jump_or_not(if_jump)
);

ID id0(
  .rst(rst),
  .pc_in(id_pc_in),
  .inst_in(id_inst_in),
  .Load_or_not(load_or_not),
  .id_stall_out(stall_id),

  .rs1_read_out(rs1_read),
  .rs2_read_out(rs2_read),
  .rs1_addr_out(rs1_address),
  .rs2_addr_out(rs2_address),

  .rs1_value_in(rs1_value),
  .rs2_value_in(rs2_value),

  .ex_forward_or_not(ex_forward_or_not),
  .ex_forward_value(ex_mem_target_data_in),
  .ex_forward_address(ex_mem_reg_address),

  .MEM_forward_or_not(mem_wb_if_operate_reg),
  .MEM_forward_value(mem_wb_rd_value),
  .MEM_forward_address(mem_wb_rd_address),

  .pc_out(id_ex_pc),
  .op_out(id_ex_op),

  .rs1_value_out(id_ex_rs1_value),
  .rs2_value_out(id_ex_rs2_value),

  .rd_address_out(id_ex_rd_address),
  .imm_out(id_ex_imm),

  .if_operate_reg_out(id_ex_if_operate_reg),
  .branch_offset_out(id_ex_branch_offset_in),
  .branch_address_out(id_ex_branch_address)
);


ID_EX id_ex0(
  .clk(clk_in),
  .rst(rst),
  .jump_or_not(if_jump),
  .stall_in(stall_status),
  .rs1_value_in(id_ex_rs1_value),
  .rs2_value_in(id_ex_rs2_value),
  .rd_address_in(id_ex_rd_address),
  .imm_in(id_ex_imm),
  .branch_address_in(id_ex_branch_address),
  .branch_offset_in(id_ex_branch_offset_in),

  .op_in(id_ex_op),
  .pc_in(id_ex_pc),


  .op_out(ex_op),
  .pc_out(ex_pc),
  .rs1_value_out(ex_rs1_value),
  .rs2_value_out(ex_rs2_value),
  .rd_address_out(ex_rd_address),
  .imm_out(ex_imm),
  .branch_address_out(ex_branch_address),
  .branch_offset_out(ex_branch_offset_in)
);

EX ex0(
  .rst(rst),
  .pc_in(ex_pc),
  .imm_in(ex_imm),
  .rs1_value_in(ex_rs1_value),
  .rs2_value_in(ex_rs2_value),
  .rd_address_in(ex_rd_address),
  .branch_address_in(ex_branch_address),
  .branch_offset_in(ex_branch_offset_in),

  .Load_or_not(load_or_not),
  .op_in(ex_op),
  .op_out(ex_mem_op),
  .status_out(ex_mem_status),
  .ex_forward_or_not(ex_forward_or_not),
  .mem_address_out(ex_mem_MEM_address),
  .target_data_out(ex_mem_target_data_in),
  .reg_address_out(ex_mem_reg_address),

  .jump_or_not(ex_jump),
  .pc_jump_out(pc_jump)


);

EX_MEM ex_mem0(
  .rst(rst),
  .clk(clk_in),
  .stall_in(stall_status),

  .op_in(ex_mem_op),
  .status_in(ex_mem_status),
  .mem_address_in(ex_mem_MEM_address),
  .target_data_in(ex_mem_target_data_in),
  .reg_address_in(ex_mem_reg_address),

  .op_out(mem_op),
  .status_out(mem_status),
  .mem_address_out(mem_MEM_address),
  .target_data_out(mem_target_data_in),
  .reg_address_out(mem_reg_address)
);

MEM mem0(
  .rst(rst),
  .op_in(mem_op),
  .status_in(mem_status),
  .mem_address_in(mem_MEM_address),
  .target_data_in(mem_target_data_in),
  .reg_address_in(mem_reg_address),

  .mc_mem_busy_in(mc_mem_busy),
  .mc_inst_busy_in(mc_inst_busy),
  .mc_enable_in(mc_to_mem_enable),
  .mc_mem_data_in(mc_mem_data),

  .mc_read_or_write_out(mem_mc_read_or_write),
  .mc_mem_enable_out(mem_mc_enable),
  .mc_width_out(mem_mc_width),
  .mc_target_data_out(mem_mc_target_data),
  .mc_mem_address_out(mem_mc_address),
  
  .if_operate_reg_out(mem_wb_if_operate_reg),
  .rd_address_out(mem_wb_rd_address),
  .rd_value_out(mem_wb_rd_value),

  .mem_stall_out(stall_mem)
);


MEM_WB mem_wb0(
  .clk(clk_in),
  .rst(rst),

  .stall_in(stall_status),

  .if_operate_reg_in(mem_wb_if_operate_reg),
  .rd_address_in(mem_wb_rd_address),
  .rd_value_in(mem_wb_rd_value),

  .if_operate_reg_out(wb_if_operate_reg),
  .rd_address_out(wb_rd_address),
  .rd_value_out(wb_rd_value)
);

memory_control memory_control0(
  .hci_if_full(io_buffer_full),
  .clk_in(clk_in),
  .rst_in(rst),
  .jump_or_not_in(if_jump),

  .mem_read_or_write_in(mem_mc_read_or_write),
  .mem_enable_in(mem_mc_enable),
  .mem_width_in(mem_mc_width),
  .mem_target_data_in(mem_mc_target_data),
  .mem_address_in(mem_mc_address),

  .inst_enable_in(icache_inst_read_out),
  .inst_address_in(icache_inst_address_out),

  .ram_data_in(mem_din),

  .mem_enable_out(mc_to_mem_enable),
  .mem_rdata_out(mc_mem_data),
  .mem_busy_out(mc_mem_busy),

  .inst_data_out(mc_inst_data),
  .inst_enable_out(mc_inst_enable),
  .inst_busy_out(mc_inst_busy),

  .ram_data_out(mem_dout),
  .ram_address_out(mem_a),
  .ram_wr(mem_wr)

);



endmodule