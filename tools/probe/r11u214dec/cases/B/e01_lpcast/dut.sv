// § modStructMemberQualSpan214 — a module localparam casting a package enum constant plus a package parameter (Earlgrey dm_csrs.sv:91)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
package top_pkg;
  localparam int TL_DBW = 4;
  localparam int TL_SZW = $clog2($clog2(TL_DBW)+1);
endpackage
module m(output logic [7:0] o);
  localparam dm::dm_csr_e DataEnd = dm::dm_csr_e'((dm::Data0 + {4'b0, dm::DataCount}));
  assign o = DataEnd;
endmodule
module top(output logic [7:0] o);
  m u(.o(o));
endmodule
