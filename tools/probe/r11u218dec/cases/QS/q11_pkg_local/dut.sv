// § pkgQualOperandSpanInParam218 — q11_pkg_local: another package's localparam reading dm qualified
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
package p2;
  localparam logic [11:0] X = dm::DataAddr + 5;
endpackage
module m(output logic [11:0] o);
  assign o = p2::X;
endmodule
module top(output logic [11:0] o);
  m u(.o(o));
endmodule
