// r10earl82 g6 — the THREE Earlgrey cells, reproduced minimally.
package pk6_82;
  localparam int MpR   = 8;    // flash_ctrl_pkg's MpRegions
  localparam int AddrW = 17;   // flash_ctrl's AddrW  (the override ACTUAL)
  localparam int RstRs = 4;    // rstmgr_pkg's ResetReasons
endpackage

// rstmgr_info: a MODULE parameter read in a PORT packed range
module rstmgr_info6 #(parameter int Reasons = 4)
  (input clk_i,
   input [Reasons-1:0] rst_req_i,
   input [Reasons:0]   data_i,
   output logic [Reasons:0] rst_reasons_o);
  assign rst_reasons_o = data_i | {1'b0, rst_req_i};
endmodule

// flash_rd_ctrl: a MODULE parameter read in a module-BODY packed range
module flash_rd6 #(parameter int AddrW = 10, parameter int DataW = 32)
  (input clk_i, input [AddrW-1:0] op_addr_i, output logic [DataW-1:0] data_o);
  logic [AddrW:0] int_addr;
  always_comb int_addr = {1'b0, op_addr_i};
  assign data_o = {{(DataW-1){1'b0}}, int_addr[0]};
endmodule

module flash_ctrl6 import pk6_82::*; (input clk_i, output logic o);
  typedef struct packed { logic [3:0] q; } mreg_t;
  mreg_t [MpR:0] region_cfgs;             // THE HEAD SHAPE
  logic [31:0] rd_data;
  logic [4:0]  reasons_o;
  always_comb region_cfgs = '0;
  rstmgr_info6 #(.Reasons(RstRs)) i_info
      (.clk_i, .rst_req_i(4'b0), .data_i(5'b0), .rst_reasons_o(reasons_o));
  flash_rd6 #(.DataW(32), .AddrW(AddrW)) u_flash_rd_ctrl
      (.clk_i, .op_addr_i({AddrW{1'b0}}), .data_o(rd_data));
  assign o = region_cfgs[0].q[0] ^ rd_data[0] ^ reasons_o[0];
endmodule
