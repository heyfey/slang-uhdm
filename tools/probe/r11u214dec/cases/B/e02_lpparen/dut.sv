// § modStructMemberQualSpan214 — a module localparam = a parenthesized package parameter expression (Earlgrey dm_mem.sv:64-65)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
package top_pkg;
  localparam int TL_DBW = 4;
  localparam int TL_SZW = $clog2($clog2(TL_DBW)+1);
endpackage
module m(output logic [11:0] o, output logic [11:0] p);
  localparam logic [11:0] DataBaseAddr = (dm::DataAddr);
  localparam logic [11:0] DataEndAddr  = (dm::DataAddr + 4*dm::DataCount);
  assign o = DataBaseAddr;
  assign p = DataEndAddr;
endmodule
module top(output logic [11:0] o, output logic [11:0] p);
  m u(.o(o), .p(p));
endmodule
