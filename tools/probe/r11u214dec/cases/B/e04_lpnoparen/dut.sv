// § modStructMemberQualSpan214 — a module localparam = a bare package parameter (control for e02's parentheses)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
package top_pkg;
  localparam int TL_DBW = 4;
  localparam int TL_SZW = $clog2($clog2(TL_DBW)+1);
endpackage
module m(output logic [11:0] o);
  localparam logic [11:0] DataBaseAddr = dm::DataAddr;
  assign o = DataBaseAddr;
endmodule
module top(output logic [11:0] o);
  m u(.o(o));
endmodule
