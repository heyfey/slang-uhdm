// v85 adversarial arm A8 — the vpiOverriden stamp under more homes and shapes.
package w85_pkg;
  parameter int AddrW  = 12;
  parameter int NoInt  = 3;
  parameter string SNAME = "x";
endpackage
package x85_pkg;
  parameter int Width = 6;
endpackage

// range reads an overridden param, wildcard import shadows it -> golden: NO stamp
module w85_a ();
  import w85_pkg::*;
  parameter int AddrW = 4;
  localparam logic [AddrW-1:0] A1 = 3;
  localparam bit   [AddrW-1:0] A2 = 3;
  localparam logic [AddrW-1:0][1:0] A3 = 0;
  localparam logic [2*AddrW-1:0] A4 = 3;
  localparam logic [AddrW:0]   A5 = 3;
endmodule

// range reads an overridden param, wildcard import declares a NON-INTEGER
// same-named member -> the predicate's else branch
module w85_b ();
  import w85_pkg::*;
  parameter int SNAME = 4;
  localparam logic [SNAME-1:0] B1 = 3;
endmodule

// gen-scope home
module w85_c ();
  import x85_pkg::*;
  parameter int Width = 4;
  genvar gj;
  for (gj = 0; gj < 2; gj++) begin : g_c
    localparam logic [Width-1:0] C1 = 3;
  end
  if (Width > 2) begin : g_yes
    localparam logic [Width-1:0] C2 = 3;
  end
endmodule

// interface home
interface w85_if ();
  import x85_pkg::*;
  parameter int Width = 4;
  localparam logic [Width-1:0] D1 = 3;
endinterface

// three instances, only some overridden
module va8_ov85 ();
  w85_a #(.AddrW(9)) u_a1 ();
  w85_a #(.AddrW(5)) u_a2 ();
  w85_a              u_a3 ();
  w85_b #(.SNAME(7)) u_b ();
  w85_c #(.Width(9)) u_c ();
  w85_c              u_c2 ();
  w85_if #(.Width(9)) u_if ();
endmodule
