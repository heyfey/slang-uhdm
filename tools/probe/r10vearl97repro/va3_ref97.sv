// v97 va3 -- A CAST TARGET WHOSE DEFAULT IS A BARE REF TO ANOTHER PARAMETER
// (not a literal, so § castTgtDefaultIsLiteral does not divert it) and a
// PACKAGE-scope target reached qualified and unqualified.
package pva3;
  parameter int PBASE = 8;
  parameter int PW    = $clog2(PBASE + 1);
  parameter int PREF  = PBASE;         // vpiExpr is a ref to another parameter
endpackage
module topva3;
  import pva3::*;
  logic [31:0] o, o2, o3;
  logic [3:0]  m;
  assign o  = 32'(PW'(m));
  assign o2 = 32'(pva3::PW'(m));
  assign o3 = 32'(PREF'(m));
  subva3 #(.InW(8)) u_s(.o());
endmodule
module subva3 #(parameter int InW = 32) (output logic [31:0] o);
  logic [3:0] m;
  localparam int WA = $clog2(InW + 1);
  localparam int WB = WA;              // ref default, typed
  assign o = 32'(WB'(m));
endmodule
