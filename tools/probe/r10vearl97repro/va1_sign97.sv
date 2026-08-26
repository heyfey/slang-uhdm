// v97 va1 -- EXPLICIT SIGNEDNESS + TYPEDEF TARGETS.  Each localparam has a
// COMPUTED default and is used as a bare `P'(x)` cast width, so the elaborated
// cast-target arm fires.  The question the law must answer: does the copied
// VpiSigned MIRROR the declaration in every written form?
package pva1;
  parameter int PB = 8;
endpackage
module topva1;
  logic [31:0] o;
  subva1 #(.InW(8)) u_s(.o(o));
endmodule
module subva1 #(parameter int InW = 32) (output logic [31:0] o);
  typedef int          ti97;
  typedef int unsigned tu97;
  typedef integer      tg97;
  logic [3:0] m;
  localparam int signed       S_SGN = $clog2(InW + 1);
  localparam int unsigned     S_UNS = $clog2(InW + 2);
  localparam int              S_PLN = $clog2(InW + 3);
  localparam ti97             S_TDI = $clog2(InW + 4);
  localparam tu97             S_TDU = $clog2(InW + 5);
  localparam tg97             S_TDG = $clog2(InW + 6);
  assign o = 32'(S_SGN'(m)) + 32'(S_UNS'(m)) + 32'(S_PLN'(m))
           + 32'(S_TDI'(m)) + 32'(S_TDU'(m)) + 32'(S_TDG'(m));
endmodule
